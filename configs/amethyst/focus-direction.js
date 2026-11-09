// Directional window focus for Amethyst, which only offers focus by window
// order. Run as: osascript -l JavaScript focus-direction.js <left|right|up|down>
//
// Mirrors Hyprland's movefocus: from the focused window, pick the closest
// window whose edge lies past it in that direction and that overlaps it on the
// other axis. Ties go to the most recently focused window (CGWindowList is
// front to back), and with nothing in that direction focus stays put. Windows
// on every display count, so focus crosses monitors like Hyprland.
//
// Window bounds come from CGWindowList (bounds need no Screen Recording grant),
// focusing goes through System Events, so the caller (skhd) needs
// Accessibility.

ObjC.import("CoreGraphics");

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
      return { pid: w.kCGWindowOwnerPID, x: b.X, y: b.Y, w: b.Width, h: b.Height };
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

function run(argv) {
  var dir = argv[0];
  if (["left", "right", "up", "down"].indexOf(dir) === -1) {
    return "usage: focus-direction.js <left|right|up|down>";
  }
  var se = Application("System Events");
  var cur = focusedWindow(se);
  var target = pick(dir, cur, onScreenWindows());
  if (target) {
    focus(se, target);
  }
}
