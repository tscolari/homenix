const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const vm = require("node:vm");

function newLayout() {
  const context = vm.createContext({ HYPR: { mfact: 0.4, resizeStep: 50, windowMargin: 10 } });
  vm.runInContext(fs.readFileSync(path.join(__dirname, "hypr-master.js"), "utf8"), context);
  return context.layout();
}

const screen = { x: 0, y: 0, width: 1000, height: 800 };
function window(id, width, isFocused = false) {
  return { id, isFocused, frame: { x: 0, y: 0, width, height: 790 } };
}

// Amethyst's FrameAssignment.impliedMainPaneRatio, including window margins.
function nativeRecommendation(assignment, physicalWidth) {
  const widthRatio = (physicalWidth + 10) / screen.width;
  return assignment.isMain ? widthRatio : 1 - widthRatio;
}

for (const secondary of ["right", "left"]) {
  test(`resizing the ${secondary} column does not use stale middle-window focus`, () => {
    const layout = newLayout();
    let state = layout.initialState;
    layout.getFrameAssignments([window("middle", 390, true), window("right", 290), window("left", 290)], screen, state);
    state = layout.updateWithChange({ change: "focus_changed", windowID: "middle" }, state);
    const windows = [window("middle", 390, true), window("right", secondary === "right" ? 190 : 290), window("left", secondary === "left" ? 190 : 290)];
    const frames = layout.getFrameAssignments(windows, screen, state);
    state = layout.recommendMainPaneRatio(nativeRecommendation(frames[secondary], 190), state);
    const resized = layout.getFrameAssignments(windows, screen, state);
    assert.equal(Math.round(resized.middle.width), 600);
    assert.equal(Math.round(resized.right.width), 200);
    assert.equal(Math.round(resized.left.width), 200);
  });
}

test("an unchanged secondary resize notification does not stretch the middle column", () => {
  const layout = newLayout();
  const windows = [window("middle", 390, true), window("right", 290), window("left", 290)];
  let state = layout.initialState;
  const frames = layout.getFrameAssignments(windows, screen, state);
  state = layout.recommendMainPaneRatio(nativeRecommendation(frames.right, 290), state);
  assert.equal(Math.round(layout.getFrameAssignments(windows, screen, state).middle.width), 400);
});

test("mouse resizing the middle column still changes its width", () => {
  const layout = newLayout();
  const windows = [window("middle", 490, true), window("right", 290), window("left", 290)];
  let state = layout.initialState;
  const frames = layout.getFrameAssignments(windows, screen, state);
  state = layout.recommendMainPaneRatio(nativeRecommendation(frames.middle, 490), state);
  assert.equal(layout.getFrameAssignments(windows, screen, state).middle.width, 500);
});

test("a side-window drag beyond the padded screen uses Amethyst's clamped ratio", () => {
  const layout = newLayout();
  const windows = [window("middle", 390), window("right", 290), window("left", 995, true)];
  let state = layout.initialState;
  layout.getFrameAssignments(windows, screen, state);
  state = layout.recommendMainPaneRatio(0, state);
  assert.equal(layout.getFrameAssignments(windows, screen, state).middle.width, 50);
});

test("an arrival inherits the destination middle width instead of its source frame", () => {
  const layout = newLayout();
  let state = layout.initialState;
  layout.getFrameAssignments([window("existing", 390, true)], screen, state);
  state = layout.commands.expandMain.updateState(state, "existing");
  const destination = layout.getFrameAssignments([window("existing", 440, true)], screen, state);
  const frames = layout.getFrameAssignments([window("incoming", 940, true), window("existing", 440)], screen, state);
  assert.equal(destination.existing.width, 450);
  assert.equal(frames.incoming.width, 450);
  assert.equal(frames.incoming.x, 275);
  assert.equal(frames.existing.width, 275);
});

test("an arrival on an empty destination takes its default middle width", () => {
  const layout = newLayout();
  const frames = layout.getFrameAssignments([window("incoming", 940, true)], screen, layout.initialState);
  assert.equal(frames.incoming.width, 400);
  assert.equal(frames.incoming.x, 300);
});
