// Hyprland's master layout, `orientation = center`, as an Amethyst custom layout.
//
// A port of CMasterAlgorithm::calculateWorkspace (center branch) and
// ::resizeTarget from Hyprland's src/layout/algorithm/tiled/master, for the
// settings in configs/hypr/settings.lua:
//
//   mfact = 0.4, orientation = center, slave_count_for_center_master = 0,
//   center_master_fallback = right.
//
// Hyprland leaves master:smart_resizing at its default (on). This port uses
// the simpler non-smart rules for heights and vertical resizing.
//
// With slave_count_for_center_master = 0 the master column is always centred,
// even when it is the only window: a lone window sits in the middle at mfact
// width. Slaves alternate between the right column (first, third, ...) and the
// left column (second, fourth, ...), each column stacked top to bottom.
//
// Amethyst's native 3column-middle is close but not the same: it gives a lone
// window the full width, and fills the left column first with a contiguous
// half of the slaves instead of alternating.
//
// Window order is Amethyst's: index 0 is the first master. With
// `new-windows-to-main: true` a new window lands there and the old master
// becomes the first slave, which is Hyprland's new_status = master plus
// new_on_top = true.
//
// Gaps are not applied here. Amethyst's window margins and screen padding
// (modules/amethyst) reproduce gaps_in / gaps_out on the frames this returns.
//
// HYPR (mfact, resizeStep) is prepended by modules/amethyst at build time.

// Last arrangement seen by getFrameAssignments. Commands only receive the
// layout state and the focused window id, while Hyprland's resize rules depend
// on which column the focused window is in, so the column map is kept here.
// Each Amethyst layout instance has its own JS context, so this is per screen.
var lastArrangement = { columns: {}, masters: 0, width: 1, height: 1 };
var focusedWindowID = null;

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

function percSizeOf(state, id) {
  var size = state.percSize[id];
  return size === undefined ? 1 : size;
}

// Hyprland's per-column stacking: each window takes heightLeft / windowsLeft
// scaled by its percSize, capped at 90% of what is left, and the last one takes
// the remainder.
function stack(ids, state, x, width, area, frames, isMain) {
  var heightLeft = area.height;
  var nextY = 0;
  for (var i = 0; i < ids.length; i++) {
    var left = ids.length - i;
    var height = left > 1 ? (heightLeft / left) * percSizeOf(state, ids[i]) : heightLeft;
    if (left > 1 && height > heightLeft * 0.9) {
      height = heightLeft * 0.9;
    }
    frames[ids[i]] = {
      x: area.x + x,
      y: area.y + nextY,
      width: width,
      height: height,
      isMain: isMain,
      unconstrainedDimension: "horizontal",
    };
    heightLeft -= height;
    nextY += height;
  }
}

// Mirror of a horizontal resizeactive by `dx` pixels on the focused window.
function resizeHorizontal(state, focusedID, dx) {
  var column = lastArrangement.columns[focusedID] || "master";
  var delta = dx / lastArrangement.width;
  if (column !== "master") {
    delta *= 2;
  }
  if (column === "left") {
    delta = -delta;
  }
  return Object.assign({}, state, {
    mainPaneRatio: clamp(state.mainPaneRatio + delta, 0.05, 0.95),
  });
}

// Mirror of a vertical resizeactive by `dy` pixels on the focused window. Only
// meaningful when the window shares its column with others.
function resizeVertical(state, focusedID, dy) {
  var column = lastArrangement.columns[focusedID];
  if (!column) {
    return state;
  }
  var inColumn = Object.keys(lastArrangement.columns).filter(function (id) {
    return lastArrangement.columns[id] === column;
  }).length;
  if (inColumn < 2) {
    return state;
  }
  var percSize = Object.assign({}, state.percSize);
  percSize[focusedID] = clamp(
    percSizeOf(state, focusedID) + dy / (lastArrangement.height / inColumn),
    0.05,
    1.95,
  );
  return Object.assign({}, state, { percSize: percSize });
}

function layout() {
  return {
    name: "Hyprland Master",
    initialState: {
      mainPaneCount: 1,
      mainPaneRatio: HYPR.mfact,
      percSize: {},
    },
    commands: {
      expandMain: {
        description: "Resize right (Hyprland resizeactive +x)",
        updateState: function (state, focusedID) {
          return resizeHorizontal(state, focusedID, HYPR.resizeStep);
        },
      },
      shrinkMain: {
        description: "Resize left (Hyprland resizeactive -x)",
        updateState: function (state, focusedID) {
          return resizeHorizontal(state, focusedID, -HYPR.resizeStep);
        },
      },
      increaseMain: {
        description: "Add master (Hyprland addmaster)",
        updateState: function (state) {
          return Object.assign({}, state, { mainPaneCount: state.mainPaneCount + 1 });
        },
      },
      decreaseMain: {
        description: "Remove master (Hyprland removemaster)",
        updateState: function (state) {
          return Object.assign({}, state, { mainPaneCount: Math.max(1, state.mainPaneCount - 1) });
        },
      },
      command1: {
        description: "Resize down (Hyprland resizeactive +y)",
        updateState: function (state, focusedID) {
          return resizeVertical(state, focusedID, HYPR.resizeStep);
        },
      },
      command2: {
        description: "Resize up (Hyprland resizeactive -y)",
        updateState: function (state, focusedID) {
          return resizeVertical(state, focusedID, -HYPR.resizeStep);
        },
      },
    },
    updateWithChange: function (change, state) {
      if (change.change === "focus_changed") {
        focusedWindowID = change.windowID;
      }
      if (change.change === "remove" && state.percSize[change.windowID] !== undefined) {
        var percSize = Object.assign({}, state.percSize);
        delete percSize[change.windowID];
        return Object.assign({}, state, { percSize: percSize });
      }
      return state;
    },
    // Mouse resizing. Amethyst reports the dragged width as a fraction of the
    // screen: w/W for frames marked isMain, 1 - w/W for the others. A slave is
    // (1 - mfact) / 2 wide, so its fraction maps back to mfact = 2x - 1. Amethyst
    // does not say which window was dragged; the focused one is assumed.
    recommendMainPaneRatio: function (ratio, state) {
      var column = lastArrangement.columns[focusedWindowID] || "master";
      var mfact = column === "master" ? ratio : 2 * ratio - 1;
      return Object.assign({}, state, { mainPaneRatio: clamp(mfact, 0.05, 0.95) });
    },
    getFrameAssignments: function (windows, screenFrame, state) {
      var ids = windows.map(function (w) {
        return w.id;
      });
      windows.forEach(function (w) {
        if (w.isFocused) {
          focusedWindowID = w.id;
        }
      });

      var masters = Math.min(state.mainPaneCount, ids.length);
      var masterIDs = ids.slice(0, masters);
      var slaveIDs = ids.slice(masters);

      var masterWidth = screenFrame.width * state.mainPaneRatio;
      var slaveWidth = (screenFrame.width - masterWidth) / 2;

      // center_master_fallback = right: the first slave goes right, then they
      // alternate.
      var right = [];
      var left = [];
      slaveIDs.forEach(function (id, index) {
        (index % 2 === 0 ? right : left).push(id);
      });

      var frames = {};
      stack(masterIDs, state, slaveWidth, masterWidth, screenFrame, frames, true);
      stack(left, state, 0, slaveWidth, screenFrame, frames, false);
      stack(right, state, slaveWidth + masterWidth, slaveWidth, screenFrame, frames, false);

      var columns = {};
      masterIDs.forEach(function (id) {
        columns[id] = "master";
      });
      left.forEach(function (id) {
        columns[id] = "left";
      });
      right.forEach(function (id) {
        columns[id] = "right";
      });
      lastArrangement = {
        columns: columns,
        masters: masters,
        width: screenFrame.width,
        height: screenFrame.height,
      };

      return frames;
    },
  };
}
