// Window focus for Amethyst, which only offers focus by window order.
//
//   osascript -l JavaScript focus.js <left|right|up|down>
//   osascript -l JavaScript focus.js roll <keycode> <flags>
//
// Directional mode mirrors Hyprland's movefocus: from the focused window, pick
// the closest window whose edge lies past it in that direction and that
// overlaps it on the other axis. Ties go to the most recently focused window
// (CGWindowList is front to back), and with nothing in that direction focus
// stays put. Windows on every display count, so focus crosses monitors like
// Hyprland.
//
// Roll mode is the focus half of Hyprland's rollnext / rollprev, which focus
// the new master. The roll itself is a layout command (hypr-master.js), and a
// layout cannot move focus. So this presses the Amethyst hotkey for the
// command (keycode + CGEventFlags), waits for a window that wasn't there before
// to appear in the master column, and focuses it. The master column is
// centred on the screen whatever mfact is, which is how it is found.
//
// Window bounds come from CGWindowList (bounds need no Screen Recording grant),
// focusing goes through System Events and the hotkey through CGEventPost, so
// the caller (skhd) needs Accessibility.

ObjC.import("CoreGraphics");
ObjC.import("AppKit");

// Overlay windows that are not real application windows.
var IGNORED_OWNERS = ["borders", "sketchybar", "Dock", "Window Server", "Control Center", "Notification Center"];
var MIN_SIZE = 50;
var TOLERANCE = 10;

function onScreenWindows() {
  var info = ObjC.deepUnwrap(
    ObjC.castRefToObject(
      $.CGWindowListCopyWindowInfo($.kCGWindowListOptionOnScreenOnly | $.kCGWindowListExcludeDesktopElements, $.kCGNullWindowID),
    ),
  );
  return info
    .filter(function (w) {
      var b = w.kCGWindowBounds;
      return (
        w.kCGWindowLayer === 0 &&
        IGNORED_OWNERS.indexOf(w.kCGWindowOwnerName) === -1 &&
        b.Width >= MIN_SIZE &&
        b.Height >= MIN_SIZE
      );
    })
    .map(function (w) {
      var b = w.kCGWindowBounds;
      return { id: w.kCGWindowNumber, pid: w.kCGWindowOwnerPID, x: b.X, y: b.Y, w: b.Width, h: b.Height };
    });
}

function focusedWindow(se) {
  var proc = se.processes.whose({ frontmost: true })[0];
  var win = proc.windows[0];
  var pos = win.position();
  var size = win.size();
  return { pid: proc.unixId(), x: pos[0], y: pos[1], w: size[0], h: size[1] };
}

function same(a, b) {
  return (
    a.pid === b.pid &&
    Math.abs(a.x - b.x) < 2 &&
    Math.abs(a.y - b.y) < 2 &&
    Math.abs(a.w - b.w) < 2 &&
    Math.abs(a.h - b.h) < 2
  );
}

function overlap(a0, a1, b0, b1) {
  return Math.min(a1, b1) - Math.max(a0, b0);
}

function pick(dir, cur, windows) {
  var horizontal = dir === "left" || dir === "right";
  var best = null;

  windows.forEach(function (w) {
    if (same(w, cur)) {
      return;
    }

    var gap;
    if (dir === "left") gap = cur.x - (w.x + w.w);
    if (dir === "right") gap = w.x - (cur.x + cur.w);
    if (dir === "up") gap = cur.y - (w.y + w.h);
    if (dir === "down") gap = w.y - (cur.y + cur.h);

    var ov = horizontal
      ? overlap(cur.y, cur.y + cur.h, w.y, w.y + w.h)
      : overlap(cur.x, cur.x + cur.w, w.x, w.x + w.w);

    if (gap < -TOLERANCE || ov <= 0) {
      return;
    }
    // Strictly closer wins; at the same distance the larger overlap wins, and
    // a full tie keeps the earlier (more recently focused) window.
    if (!best || gap < best.gap - 1 || (Math.abs(gap - best.gap) <= 1 && ov > best.ov)) {
      best = { win: w, gap: gap, ov: ov };
    }
  });

  return best ? best.win : null;
}

// Index specifiers (windows[i]) rather than windows(): the array form returns
// references that System Events can no longer resolve once the process has
// been brought to the front ("Can't get object").
function focus(se, target) {
  var proc = se.processes.whose({ unixId: target.pid })[0];
  proc.frontmost = true;
  var count = proc.windows.length;
  for (var i = 0; i < count; i++) {
    var win = proc.windows[i];
    var pos = win.position();
    var size = win.size();
    if (count === 1 || same({ pid: target.pid, x: pos[0], y: pos[1], w: size[0], h: size[1] }, target)) {
      win.actions.byName("AXRaise").perform();
      return;
    }
  }
}

// Posted at the HID level, like a real key press, which is where Amethyst's
// hotkeys are matched.
function pressHotkey(keyCode, flags) {
  [true, false].forEach(function (down) {
    var event = $.CGEventCreateKeyboardEvent(null, keyCode, down);
    $.CGEventSetFlags(event, flags);
    $.CGEventPost($.kCGHIDEventTap, event);
  });
}

// The screen holding the centre of `win`, in CGWindowList coordinates (origin
// top-left of the primary screen, y down). NSScreen frames have y up.
function screenOf(win) {
  var cx = win.x + win.w / 2;
  var cy = win.y + win.h / 2;
  var screens = $.NSScreen.screens.js;
  var primaryHeight = screens[0].frame.size.height;
  for (var i = 0; i < screens.length; i++) {
    var f = screens[i].frame;
    var s = { x: f.origin.x, y: primaryHeight - f.origin.y - f.size.height, w: f.size.width, h: f.size.height };
    if (cx >= s.x && cx < s.x + s.w && cy >= s.y && cy < s.y + s.h) {
      return s;
    }
  }
  return null;
}

function masterColumn(screen) {
  var mid = screen.x + screen.w / 2;
  return onScreenWindows().filter(function (w) {
    var cy = w.y + w.h / 2;
    return Math.abs(w.x + w.w / 2 - mid) <= TOLERANCE && cy >= screen.y && cy < screen.y + screen.h;
  });
}

var ROLL_TIMEOUT = 1.0;
var ROLL_POLL = 0.02;

function roll(se, keyCode, flags) {
  var screen = screenOf(focusedWindow(se));
  if (!screen) {
    return;
  }
  var before = masterColumn(screen);

  pressHotkey(keyCode, flags);

  // A roll only trades windows between slots, so the new master lands exactly
  // on a frame the master column had before. Amethyst sets position and size
  // separately, and focus() matches windows by frame, so anything in between
  // (a window passing through the column, or a half-applied frame) is skipped.
  for (var waited = 0; waited < ROLL_TIMEOUT; waited += ROLL_POLL) {
    delay(ROLL_POLL);
    var arrived = masterColumn(screen).filter(function (w) {
      return before.every(function (b) {
        return b.id !== w.id;
      }) && before.some(function (b) {
        return same(Object.assign({}, b, { pid: w.pid }), w);
      });
    })[0];
    if (arrived) {
      focus(se, arrived);
      return;
    }
  }
}

function run(argv) {
  var se = Application("System Events");
  if (argv[0] === "roll" && argv.length === 3) {
    roll(se, parseInt(argv[1], 10), parseInt(argv[2], 10));
    return;
  }
  var dir = argv[0];
  if (["left", "right", "up", "down"].indexOf(dir) === -1) {
    return "usage: focus.js <left|right|up|down> | roll <keycode> <flags>";
  }
  var target = pick(dir, focusedWindow(se), onScreenWindows());
  if (target) {
    focus(se, target);
  }
}
