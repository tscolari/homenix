// Native Space moves for Amethyst, including Ghostty's hidden titlebar.
//
//   osascript -l JavaScript move-space.js <1..9|left|right>
//
// Amethyst's own throw uses a titlebar drag. Its mouse handlers also consume
// that synthetic drag and can mistake reflow resizes for user input. Keep
// them off during the gesture, then refresh tracking after the window arrives.
// Ghostty's hidden window uses macOS's Option-drag on the resize border.
//
// AMETHYST_KEYS (reevaluate, swapPrevious: { keyCode, flags }) is prepended by
// modules/amethyst from the Amethyst bindings it generates.

ObjC.import("AppKit");
ObjC.import("CoreGraphics");
ObjC.import("ApplicationServices");
ObjC.bindFunction("_AXUIElementGetWindow", ["int", ["void *", "unsigned int *"]]);
// AX references are opaque pointers, not Objective-C objects.
ObjC.bindFunction("CFRelease", ["void", ["void *"]]);
ObjC.bindFunction("CGSMainConnectionID", ["int", []]);
ObjC.bindFunction("CGSCopyManagedDisplaySpaces", ["id", ["int"]]);
ObjC.bindFunction("CGSCopySpacesForWindows", ["id", ["int", "int", "id"]]);
ObjC.bindFunction("CGSManagedDisplayIsAnimating", ["bool", ["int", "id"]]);
// A kernel lock: the system releases it when the process exits, even on a crash.
ObjC.bindFunction("open", ["int", ["char *", "int"]]);
ObjC.bindFunction("flock", ["int", ["int", "int"]]);
ObjC.bindFunction("close", ["int", ["int"]]);

var AMETHYST_DOMAIN = "com.amethyst.Amethyst";
var MOUSE_SETTINGS = ["mouse-resizes-windows", "mouse-swaps-windows", "focus-follows-mouse"];
var OPTION = 524288;
var TIMEOUT = 3;
var POLL = 0.02;
var LOCK_EX_NB = 2 | 4;
// focus.js uses the same owners and minimum size for real application windows.
var IGNORED_OWNERS = ["borders", "sketchybar", "Dock", "Window Server", "Control Center", "Notification Center"];
var MIN_SIZE = 50;

function validateArgument(argument) {
  if (!/^([1-9]|left|right)$/.test(argument)) {
    throw new Error("Expected a desktop number 1..9, left, or right");
  }
}

function destination(argument, displays, sourceID) {
  var spaces = [];
  displays.forEach(function (display) {
    display.Spaces.forEach(function (space) {
      if (space.type === 0) {
        spaces.push({ id: space.ManagedSpaceID, display: display["Display Identifier"] });
      }
    });
  });
  var source = spaces.findIndex(function (space) { return space.id === sourceID; });
  if (source === -1) {
    throw new Error("The focused window is not on a normal desktop");
  }
  var index;
  if (argument === "left" || argument === "right") {
    index = source + (argument === "left" ? -1 : 1);
    if (index < 0 || index >= spaces.length) {
      return null;
    }
  } else {
    validateArgument(argument);
    index = Number(argument) - 1;
    if (index >= spaces.length) {
      throw new Error("Desktop " + argument + " does not exist");
    }
  }
  if (index === source) {
    return null;
  }
  return {
    id: spaces[index].id,
    display: spaces[index].display,
    shortcutID: 118 + index,
    sourceID: sourceID,
    sourceDisplay: spaces[source].display,
    sourceShortcutID: 118 + source,
  };
}

// Mirrors Amethyst's UserConfiguration: the floating list (exact or "*" IDs,
// optionally narrowed by window-title regexes) is a blacklist or a whitelist,
// and small windows float when float-small-windows is on. Windows floated at
// runtime with toggle-float are not visible from outside Amethyst.
function floatsByDefault(rules, bundleID, title, frame) {
  if (rules.floatSmallWindows && frame.width < rules.smallWindowSize && frame.height < rules.smallWindowSize) {
    return true;
  }
  var entry = null;
  (rules.bundles || []).some(function (raw) {
    var bundle = typeof raw === "string" ? { id: raw, titles: [] }
      : raw.id ? { id: raw.id, titles: raw["window-titles"] || [] }
      : Object.keys(raw).length === 1 ? { id: Object.keys(raw)[0], titles: raw[Object.keys(raw)[0]]["window-titles"] || [] }
      : null;
    var matches = bundle && (bundle.id.indexOf("*") === -1 ? bundle.id === bundleID
      : new RegExp("^" + bundle.id.replace(/\./g, "\\.").replace(/\*/g, ".*") + "$").test(bundleID || ""));
    if (matches) {
      entry = bundle;
    }
    return matches;
  });
  if (!entry) {
    return !rules.isBlacklist;
  }
  if (entry.titles.length === 0) {
    return rules.isBlacklist;
  }
  var titled = typeof title === "string" && entry.titles.some(function (pattern) {
    return new RegExp(pattern).test(title);
  });
  return titled ? rules.isBlacklist : !rules.isBlacklist;
}

// The centered master layout keeps a centered column with room for side
// columns. bsp and fullscreen only centre windows that span the whole width.
function hasCenteredColumn(frames, middleX, area) {
  return frames.some(function (f) {
    return Math.abs(f.x + f.width / 2 - middleX) <= 2 && f.x - area.x >= MIN_SIZE;
  });
}

function grabPoint(frame, minimizeButton, bundleID) {
  if (minimizeButton) {
    return {
      x: minimizeButton.x + minimizeButton.width / 2,
      y: frame.y + (minimizeButton.y - frame.y) / 2,
      flags: 0,
    };
  }
  if (bundleID === "com.mitchellh.ghostty") {
    return { x: frame.x + frame.width / 2, y: frame.y + 1, flags: OPTION, dragX: frame.x + frame.width / 2 + 20 };
  }
  throw new Error("The focused window (" + bundleID + ") exposes no draggable titlebar");
}

function waitFor(predicate, message, seconds) {
  var deadline = Date.now() + (seconds || TIMEOUT) * 1000;
  while (!predicate()) {
    if (Date.now() >= deadline) {
      throw new Error(message);
    }
    delay(POLL);
  }
}

// Tiles never overlap and stay on screen. Amethyst resizes a window before
// moving it, so mid-reflow a window can sit at its old origin on top of a
// neighbour or past the screen edge.
function settled(frames, area) {
  return frames.every(function (a, i) {
    return a.x >= area.x - 2 && a.x + a.width <= area.x + area.width + 2 &&
      frames.slice(i + 1).every(function (b) {
        return Math.min(a.x + a.width, b.x + b.width) - Math.max(a.x, b.x) <= 1 ||
          Math.min(a.y + a.height, b.y + b.height) - Math.max(a.y, b.y) <= 1;
      });
  });
}

// Cached returnees are not new IDs to the layout. Move them through the
// existing order until centered; swap-main would toggle an already-native main.
// Every decision reads a settled layout ({ arrival, tiled } from readLayout)
// that also reads the same twice in a row.
function promoteToMiddle(readLayout, middleX, area, windowCount, movePrevious, waitUntil) {
  var layout;
  function waitSettled(message, changedFrom, seconds) {
    var last = null;
    waitUntil(function () {
      layout = readLayout();
      var a = layout.arrival;
      var moved = !changedFrom || a.x !== changedFrom.x || a.y !== changedFrom.y ||
        a.width !== changedFrom.width || a.height !== changedFrom.height;
      var snapshot = JSON.stringify(layout);
      var stable = snapshot === last;
      last = snapshot;
      return moved && stable && settled([a].concat(layout.tiled), area);
    }, message, seconds);
  }
  // Layouts that stack windows (fullscreen) never stop overlapping. A reflow
  // settles well within a second; past that there is no tiled layout to place
  // the arrival in, so leave it where Amethyst put it.
  try {
    waitSettled("Amethyst did not finish laying out the arriving window", null, 1);
  } catch (_) {
    return;
  }
  if (!hasCenteredColumn(layout.tiled, middleX, area)) {
    return;
  }
  for (var i = 0; i < windowCount; i++) {
    if (Math.abs(layout.arrival.x + layout.arrival.width / 2 - middleX) <= 2) {
      return;
    }
    movePrevious();
    waitSettled("Amethyst did not finish moving the arriving window toward the middle", layout.arrival);
  }
  throw new Error("Amethyst could not place the arriving window in the middle column");
}

function postKey(keyCode, flags) {
  [true, false].forEach(function (down) {
    var event = $.CGEventCreateKeyboardEvent(null, keyCode, down);
    $.CGEventSetFlags(event, down ? flags : 0);
    $.CGEventPost($.kCGHIDEventTap, event);
  });
}

function postMouse(type, point, flags) {
  var event = $.CGEventCreateMouseEvent(null, type, { x: point.x, y: point.y }, $.kCGMouseButtonLeft);
  $.CGEventSetFlags(event, flags);
  $.CGEventPost($.kCGHIDEventTap, event);
}

function acquireMoveLock() {
  var path = $.NSTemporaryDirectory().stringByAppendingPathComponent("homenix-amethyst-space-move.flock");
  var files = $.NSFileManager.defaultManager;
  if (!files.fileExistsAtPath(path)) {
    files.createFileAtPathContentsAttributes(path, $(), $());
  }
  var fd = $.open(path.js, 0);
  if (fd < 0) {
    throw new Error("Cannot open the window move lock");
  }
  if ($.flock(fd, LOCK_EX_NB) !== 0) {
    $.close(fd);
    throw new Error("A window move is already in progress");
  }
  return fd;
}

function run(argv) {
  validateArgument(argv[0]);
  var lock = acquireMoveLock();
  var prefs = $.NSUserDefaults.alloc.initWithSuiteName(AMETHYST_DOMAIN);
  var saved = [];
  var held = false;
  var releasedAt = 0;
  var pointer = null;
  var point = null;
  try {
    var connection = $.CGSMainConnectionID();
    var se = Application("System Events");
    var pid = se.processes.whose({ frontmost: true })[0].unixId();
    var process = se.processes.whose({ unixId: pid })[0];
    var win = process.attributes.byName("AXFocusedWindow").value();
    var applicationElement = $.AXUIElementCreateApplication(pid);
    var focusedElement = Ref();
    var focusError = $.AXUIElementCopyAttributeValue(applicationElement, $("AXFocusedWindow"), focusedElement);
    if (focusError !== 0) {
      $.CFRelease(applicationElement);
      throw new Error("Cannot read the focused Accessibility window");
    }
    var focusedID = Ref();
    var identityError = $._AXUIElementGetWindow(focusedElement[0], focusedID);
    $.CFRelease(focusedElement[0]);
    $.CFRelease(applicationElement);
    if (identityError !== 0 || !focusedID[0]) {
      throw new Error("Cannot identify the focused Accessibility window");
    }
    var windowID = focusedID[0];
    var info = ObjC.deepUnwrap(ObjC.castRefToObject(
      $.CGWindowListCopyWindowInfo($.kCGWindowListOptionOnScreenOnly, $.kCGNullWindowID),
    ));
    var current = info.find(function (w) {
      return w.kCGWindowNumber === windowID;
    });
    if (!current) {
      throw new Error("Cannot identify the focused window");
    }
    var bounds = current.kCGWindowBounds;
    var frame = { x: bounds.X, y: bounds.Y, width: bounds.Width, height: bounds.Height };
    function windowSpaces() {
      return ObjC.deepUnwrap($.CGSCopySpacesForWindows(connection, 7, $([windowID])));
    }
    var displays = ObjC.deepUnwrap($.CGSCopyManagedDisplaySpaces(connection));
    var target = destination(argv[0], displays, windowSpaces()[0]);
    if (!target) {
      return;
    }
    var hotkeys = $.NSUserDefaults.alloc.initWithSuiteName("com.apple.symbolichotkeys");
    var shortcuts = ObjC.deepUnwrap(hotkeys.objectForKey("AppleSymbolicHotKeys"));
    var shortcut = shortcuts[String(target.shortcutID)];
    var follow = prefs.boolForKey("follow-space-thrown-windows");
    var returnShortcut = follow ? null : shortcuts[String(target.sourceShortcutID)];
    if (!shortcut || !shortcut.enabled || !shortcut.value || !shortcut.value.parameters ||
        (!follow && (!returnShortcut || !returnShortcut.enabled || !returnShortcut.value || !returnShortcut.value.parameters))) {
      throw new Error("Enable the native Switch to Desktop shortcuts for this move");
    }
    var minimizeButton = null;
    try {
      var button = win.attributes.byName("AXMinimizeButton").value();
      var buttonPos = button.position();
      var buttonSize = button.size();
      minimizeButton = { x: buttonPos[0], y: buttonPos[1], width: buttonSize[0], height: buttonSize[1] };
    } catch (_) {
      // Hidden Ghostty windows have no titlebar controls.
    }
    var bundleID = process.bundleIdentifier();
    var title = null;
    try {
      title = win.attributes.byName("AXTitle").value();
    } catch (_) {
      // Amethyst treats a missing title as "no title rule matched".
    }
    point = grabPoint(frame, minimizeButton, bundleID);
    pointer = $.CGEventGetLocation($.CGEventCreate(null));
    prefs.synchronize;
    MOUSE_SETTINGS.forEach(function (key) {
      saved.push({ key: key, value: prefs.objectForKey(key) });
      prefs.setBoolForKey(false, key);
    });
    prefs.synchronize;

    postMouse($.kCGEventMouseMoved, point, 0);
    held = true;
    postMouse($.kCGEventLeftMouseDown, point, point.flags);
    // Hidden windows need motion along the border to start a move, not a resize.
    postMouse($.kCGEventLeftMouseDragged, { x: point.dragX || point.x, y: point.y }, point.flags);
    // Let AppKit consume the grab before switching the desktop underneath it.
    delay(0.05);
    postKey(shortcut.value.parameters[1], shortcut.value.parameters[2]);
    waitFor(function () {
      var activeDisplays = ObjC.deepUnwrap($.CGSCopyManagedDisplaySpaces(connection));
      return activeDisplays.some(function (display) {
        return display["Display Identifier"] === target.display &&
          display["Current Space"].ManagedSpaceID === target.id &&
          !$.CGSManagedDisplayIsAnimating(connection, $(target.display));
      });
    }, "The destination desktop did not finish switching");
    postMouse($.kCGEventLeftMouseUp, { x: point.dragX || point.x, y: point.y }, 0);
    held = false;
    releasedAt = Date.now();
    waitFor(function () { return windowSpaces().indexOf(target.id) !== -1; }, "The window did not reach the destination desktop");
    postKey(AMETHYST_KEYS.reevaluate.keyCode, AMETHYST_KEYS.reevaluate.flags);
    // MouseStateKeeper may associate delayed AX events with a release for 150ms.
    // Keep synthetic input excluded until that known interval has expired.
    waitFor(function () { return Date.now() - releasedAt >= 200; }, "Mouse release did not settle");
    function onScreenInfo() {
      return ObjC.deepUnwrap(ObjC.castRefToObject(
        $.CGWindowListCopyWindowInfo($.kCGWindowListOptionOnScreenOnly, $.kCGNullWindowID),
      ));
    }
    function readArrivingFrame() {
      var arrival = onScreenInfo().find(function (w) { return w.kCGWindowNumber === windowID; });
      if (!arrival) {
        throw new Error("The arriving window is no longer visible");
      }
      var b = arrival.kCGWindowBounds;
      return { x: b.X, y: b.Y, width: b.Width, height: b.Height };
    }
    var arrivalFrame = readArrivingFrame();
    var screens = $.NSScreen.screens.js;
    var primaryHeight = screens[0].frame.size.height;
    var arrivalScreen = screens.find(function (screen) {
      var f = screen.frame;
      var cx = arrivalFrame.x + arrivalFrame.width / 2;
      var cy = arrivalFrame.y + arrivalFrame.height / 2;
      var top = primaryHeight - f.origin.y - f.size.height;
      return cx >= f.origin.x && cx < f.origin.x + f.size.width && cy >= top && cy < top + f.size.height;
    });
    if (!arrivalScreen) {
      throw new Error("Cannot identify the arriving window's screen");
    }
    var screenTop = primaryHeight - arrivalScreen.frame.origin.y - arrivalScreen.frame.size.height;
    var area = prefs.boolForKey("ignore-menu-bar") ? arrivalScreen.frame : arrivalScreen.visibleFrame;
    var middleX = area.origin.x + area.size.width / 2 +
      (prefs.floatForKey("screen-padding-left") - prefs.floatForKey("screen-padding-right")) / 2;
    var floating = prefs.objectForKey("floating");
    var smallWindowSize = prefs.floatForKey("small-window-size");
    var rules = {
      bundles: floating.isNil() ? [] : ObjC.deepUnwrap(floating),
      isBlacklist: prefs.objectForKey("floating-is-blacklist").isNil() || prefs.boolForKey("floating-is-blacklist"),
      floatSmallWindows: prefs.boolForKey("float-small-windows"),
      smallWindowSize: smallWindowSize > 0 ? smallWindowSize : 500,
    };
    var bundles = {};
    function tiledFrame(w) {
      var b = w.kCGWindowBounds;
      var cx = b.X + b.Width / 2;
      var cy = b.Y + b.Height / 2;
      if (w.kCGWindowNumber === windowID || w.kCGWindowLayer !== 0 || IGNORED_OWNERS.indexOf(w.kCGWindowOwnerName) !== -1 ||
          b.Width < MIN_SIZE || b.Height < MIN_SIZE ||
          cx < arrivalScreen.frame.origin.x || cx >= arrivalScreen.frame.origin.x + arrivalScreen.frame.size.width ||
          cy < screenTop || cy >= screenTop + arrivalScreen.frame.size.height) {
        return null;
      }
      var pid = w.kCGWindowOwnerPID;
      if (!(pid in bundles)) {
        var owner = $.NSRunningApplication.runningApplicationWithProcessIdentifier(pid);
        bundles[pid] = owner.isNil() ? null : ObjC.unwrap(owner.bundleIdentifier);
      }
      var frame = { x: b.X, y: b.Y, width: b.Width, height: b.Height };
      return floatsByDefault(rules, bundles[pid], w.kCGWindowName || null, frame) ? null : frame;
    }
    function readLayout() {
      var visible = onScreenInfo();
      var arrival = visible.find(function (w) { return w.kCGWindowNumber === windowID; });
      if (!arrival) {
        throw new Error("The arriving window is no longer visible");
      }
      var b = arrival.kCGWindowBounds;
      return {
        arrival: { x: b.X, y: b.Y, width: b.Width, height: b.Height },
        tiled: visible.map(tiledFrame).filter(function (f) { return f; }),
      };
    }
    // Floating arrivals keep their own frame, and promoteToMiddle leaves other
    // layouts (bsp, fullscreen) alone; swap-ccw would reorder their windows or
    // reset focus.
    if (!floatsByDefault(rules, bundleID, title, arrivalFrame)) {
      var windowCount = onScreenInfo().filter(function (w) { return w.kCGWindowLayer === 0; }).length;
      promoteToMiddle(readLayout, middleX, { x: area.origin.x, width: area.size.width }, windowCount, function () {
        postKey(AMETHYST_KEYS.swapPrevious.keyCode, AMETHYST_KEYS.swapPrevious.flags);
      }, waitFor);
    }
    if (!follow) {
      postKey(returnShortcut.value.parameters[1], returnShortcut.value.parameters[2]);
      waitFor(function () {
        return ObjC.deepUnwrap($.CGSCopyManagedDisplaySpaces(connection)).some(function (display) {
          return display["Display Identifier"] === target.sourceDisplay &&
            display["Current Space"].ManagedSpaceID === target.sourceID &&
            !$.CGSManagedDisplayIsAnimating(connection, $(target.sourceDisplay));
        });
      }, "The original desktop did not finish switching");
    }
  } finally {
    try {
      if (held) {
        postMouse($.kCGEventLeftMouseUp, point, 0);
        releasedAt = Date.now();
      }
      if (releasedAt) {
        waitFor(function () { return Date.now() - releasedAt >= 200; }, "Mouse release did not settle");
      }
      if (pointer) {
        postMouse($.kCGEventMouseMoved, pointer, 0);
      }
    } finally {
      saved.forEach(function (entry) {
        if (entry.value && !entry.value.isNil()) {
          prefs.setObjectForKey(entry.value, entry.key);
        } else {
          prefs.removeObjectForKey(entry.key);
        }
      });
      prefs.synchronize;
      $.close(lock);
    }
  }
}
