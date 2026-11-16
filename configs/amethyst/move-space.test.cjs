const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const vm = require("node:vm");

// The selection and grab calculations are pure; only framework loading needs
// a stand-in outside macOS's JavaScript for Automation runtime.
const context = vm.createContext({ ObjC: { import() {}, bindFunction() {} } });
vm.runInContext(fs.readFileSync(path.join(__dirname, "move-space.js"), "utf8"), context);
const displays = [{
  "Display Identifier": "display",
  Spaces: [
    { ManagedSpaceID: 1, type: 0 },
    { ManagedSpaceID: 20, type: 4 },
    { ManagedSpaceID: 3, type: 0 },
    { ManagedSpaceID: 7, type: 0 },
  ],
}];

test("relative moves use desktop order and skip fullscreen Spaces", () => {
  assert.equal(context.destination("right", displays, 1).id, 3);
  assert.equal(context.destination("left", displays, 7).id, 3);
  assert.equal(context.destination("3", displays, 1).shortcutID, 120);
});

test("same-desktop and relative boundary moves do not start a drag", () => {
  assert.equal(context.destination("2", displays, 3), null);
  assert.equal(context.destination("left", displays, 1), null);
  assert.equal(context.destination("right", displays, 7), null);
});

test("nonexistent and malformed desktop requests are rejected", () => {
  assert.throws(() => context.destination("4", displays, 1), /does not exist/);
  assert.throws(() => context.destination("0", displays, 1), /Expected a desktop/);
  assert.throws(() => context.destination("3garbage", displays, 1), /Expected a desktop/);
  assert.throws(() => context.destination("1", displays, 20), /normal desktop/);
});

test("hidden Ghostty uses Option on the native resize border", () => {
  const point = context.grabPoint({ x: 100, y: 26, width: 1000, height: 800 }, null, "com.mitchellh.ghostty");
  assert.equal(point.x, 600);
  assert.equal(point.y, 27);
  assert.equal(point.flags, 524288);
});

test("ordinary windows are grabbed above the minimize control", () => {
  const point = context.grabPoint({ x: 100, y: 26, width: 1000, height: 800 }, { x: 120, y: 40, width: 12, height: 12 }, "org.mozilla.firefox");
  assert.equal(point.x, 126);
  assert.equal(point.y, 33);
  assert.equal(point.flags, 0);
});

test("unsupported titlebar-free windows fail before mouse input", () => {
  assert.throws(() => context.grabPoint({ x: 0, y: 0, width: 800, height: 600 }, null, "other.app"), /draggable titlebar/);
});

const rules = {
  bundles: [
    "com.apple.Preview",
    "com.example.*",
    { id: "org.example.titled", "window-titles": ["^Picture"] },
    { "org.example.keyed": { "window-titles": ["Settings"] } },
  ],
  isBlacklist: true,
  floatSmallWindows: true,
  smallWindowSize: 500,
};
const large = { x: 0, y: 0, width: 800, height: 600 };

test("arrivals use Amethyst's default floating rules", () => {
  assert.equal(context.floatsByDefault(rules, "com.apple.Preview", "doc.pdf", large), true);
  assert.equal(context.floatsByDefault(rules, "com.example.tool", null, large), true);
  assert.equal(context.floatsByDefault(rules, "us.zoom.xos", "Zoom Meeting", large), false);
  assert.equal(context.floatsByDefault(rules, "org.example.titled", "Picture in Picture", large), true);
  assert.equal(context.floatsByDefault(rules, "org.example.titled", "Main", large), false);
  assert.equal(context.floatsByDefault(rules, "org.example.titled", null, large), false);
  assert.equal(context.floatsByDefault(rules, "org.example.keyed", "App Settings", large), true);
  assert.equal(context.floatsByDefault(rules, "com.mitchellh.ghostty", "zsh", { x: 0, y: 0, width: 400, height: 300 }), true);
  assert.equal(context.floatsByDefault({ ...rules, isBlacklist: false }, "com.apple.Preview", "doc.pdf", large), false);
  assert.equal(context.floatsByDefault({ ...rules, isBlacklist: false }, "com.mitchellh.ghostty", "zsh", large), true);
});

test("only a centered column with room on both sides enables promotion", () => {
  const area = { x: 0, width: 5120 };
  // Centered master layout, including a narrow mfact and a near-maximal one.
  assert.equal(context.hasCenteredColumn([{ x: 1543, width: 2034 }, { x: 10, width: 1523 }], 2560, area), true);
  assert.equal(context.hasCenteredColumn([{ x: 133, width: 4854 }], 2560, area), true);
  // bsp halves, a bsp full-width row, and fullscreen layout.
  assert.equal(context.hasCenteredColumn([{ x: 5, width: 2550 }, { x: 2565, width: 2550 }], 2560, area), false);
  assert.equal(context.hasCenteredColumn([{ x: 5, width: 5110 }], 2560, area), false);
  assert.equal(context.hasCenteredColumn([], 2560, area), false);
});

test("invalid desktop requests fail before taking the move lock", () => {
  // The test context has no Objective-C bridge, so reaching the lock throws a
  // ReferenceError instead of the argument error.
  assert.throws(() => context.run(["0"]), /Expected a desktop/);
  assert.throws(() => context.run([]), /Expected a desktop/);
});

function cachedDestination(nativeOrder, rolled = false) {
  const layoutContext = vm.createContext({ HYPR: { mfact: 0.55, resizeStep: 50, windowMargin: 10 } });
  vm.runInContext(fs.readFileSync(path.join(__dirname, "hypr-master.js"), "utf8"), layoutContext);
  const layout = layoutContext.layout();
  let state = layout.initialState;
  const screen = { x: 0, y: 0, width: 1000, height: 800 };
  let frames;
  function arrange(ids) {
    frames = layout.getFrameAssignments(ids.map(id => ({
      id, isFocused: id === "incoming",
      frame: { x: 0, y: 0, width: 290, height: 790 },
    })), screen, state);
  }
  arrange(["middle", "right", "incoming", "left"]);
  if (rolled) {
    state = layout.commands.command3.updateState(state, "middle");
    arrange(["middle", "right", "incoming", "left"]);
  }
  // The destination wasn't reflowed while inactive. Its cached incoming ID
  // remains a secondary; native re-evaluation keeps that old placement.
  arrange(nativeOrder);
  const inset = f => ({ x: f.x + 5, y: f.y + 5, width: f.width - 10, height: f.height - 10 });
  // Amethyst resizes a window before moving it. Until a reflow finishes, reads
  // can see the arrival at a stale origin, overlapping a tiled neighbour. The
  // first read shows it where it was dropped: over the destination's middle.
  let transient = inset(frames.middle);
  return {
    readLayout() {
      const all = Object.keys(frames).map(id => ({ id, frame: inset(frames[id]) }));
      const arrival = transient || all.find(w => w.id === "incoming").frame;
      transient = null;
      return { arrival, tiled: all.filter(w => w.id !== "incoming").map(w => w.frame) };
    },
    movePrevious() {
      const before = inset(frames.incoming);
      const from = nativeOrder.indexOf("incoming");
      const to = (from - 1 + nativeOrder.length) % nativeOrder.length;
      state = layout.updateWithChange({ change: "window_swap", windowID: "incoming", otherWindowID: nativeOrder[to] }, state);
      [nativeOrder[from], nativeOrder[to]] = [nativeOrder[to], nativeOrder[from]];
      arrange(nativeOrder);
      const after = inset(frames.incoming);
      transient = { x: before.x, y: before.y, width: after.width, height: after.height };
    },
    assignments() { return frames; },
  };
}

function poll(predicate, message) {
  for (let i = 0; i < 5; i++) {
    if (predicate()) {
      return;
    }
  }
  assert.fail(message);
}

test("a stacked destination layout is left alone instead of timing out", () => {
  // Fullscreen (and a bsp tree Amethyst failed to restore) keeps windows on
  // top of each other, so the layout never settles.
  const full = { x: 5, y: 5, width: 990, height: 790 };
  let swaps = 0;
  context.promoteToMiddle(() => ({ arrival: { ...full }, tiled: [{ ...full }] }), 500, { x: 0, width: 1000 }, 4,
    () => { swaps++; }, poll);
  assert.equal(swaps, 0);
});

test("a settled bsp destination is left alone", () => {
  let swaps = 0;
  context.promoteToMiddle(() => ({
    arrival: { x: 505, y: 5, width: 490, height: 790 },
    tiled: [{ x: 5, y: 5, width: 490, height: 790 }],
  }), 500, { x: 0, width: 1000 }, 4, () => { swaps++; }, poll);
  assert.equal(swaps, 0);
});

for (const [name, ids, rolled] of [
  ["cached secondary", ["middle", "right", "incoming", "left"], false],
  ["first window in Amethyst's separate order", ["incoming", "middle", "right", "left"], false],
  ["previously rolled destination", ["middle", "right", "incoming", "left"], true],
]) {
  test(`a returning ${name} becomes the middle window without changing its width`, () => {
    const destination = cachedDestination(ids, rolled);
    assert.equal(destination.assignments().incoming.isMain, false);
    context.promoteToMiddle(destination.readLayout, 500, { x: 0, width: 1000 }, 4, destination.movePrevious, poll);
    const frames = destination.assignments();
    assert.equal(frames.incoming.isMain, true);
    assert.equal(frames.incoming.x, 225);
    assert.equal(frames.incoming.width, 550);
    assert.equal(frames.middle.width, 225);
  });
}
