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
// Window order (index 0 is the first master) is kept here rather than taken
// from Amethyst: Hyprland's rollnext / rollprev rotate it, and a custom layout
// cannot reorder Amethyst's own list. Amethyst's operations carry over:
//
// - New windows go to the front (`new-windows-to-main: true`), which is
//   Hyprland's new_status = master plus new_on_top = true. Closed ones drop out.
// - Amethyst picks a swap partner by its own order: the next / previous window
//   for swap-cw / swap-ccw, the first for swap-main. Once a roll has made the
//   two orders differ, the partner is translated to the same position in this
//   order (translateSwap). Until then the orders are identical and swaps pass
//   through unchanged.
//
// Gaps are not applied here. Amethyst's window margins and screen padding
// (modules/amethyst) reproduce gaps_in / gaps_out on the frames this returns.
//
// HYPR (mfact, resizeStep) is prepended by modules/amethyst at build time.

// Last arrangement seen by getFrameAssignments. Commands only receive the
// layout state and the focused window id, while Hyprland's resize rules depend
// on which column the focused window is in, so the column map is kept here.
// Amethyst creates a layout instance, with its own JS context, per screen and
// desktop, so all of this is per desktop.
var lastArrangement = { columns: {}, masters: 0, width: 1, height: 1 };
var focusedWindowID = null;

// The display order, and Amethyst's order as of the last getFrameAssignments.
// Swap events arrive before the reflow, so that is the pre-swap order.
var order = [];
var amethystOrder = [];

// Windows still tiled keep their place; the rest go in front, in Amethyst's
// order.
function reconcile(ids) {
  var kept = order.filter(function (id) {
    return ids.indexOf(id) !== -1;
  });
  var added = ids.filter(function (id) {
    return kept.indexOf(id) === -1;
  });
  order = added.concat(kept);
  amethystOrder = ids;
  return order;
}

// Amethyst swapped `id` with `otherID`, picked from Amethyst's order. Returns
// the window in the same relative position of the display order.
//
// The events carry no command, so some cases look identical. A partner first
// in Amethyst's order is read as swap-main, even when it was swap-cw from the
// last window or swap-ccw from the second. A drag onto the next, previous or
// first window reads as the keyboard swap. Once the orders differ, those land
// on the translated partner.
function translateSwap(id, otherID) {
  var n = amethystOrder.length;
  var from = amethystOrder.indexOf(id);
  var to = amethystOrder.indexOf(otherID);
  var at = order.indexOf(id);
  if (from === -1 || to === -1 || at === -1 || order.length !== n) {
    return otherID;
  }
  if (to === 0 && from !== 0) {
    return order[0];
  }
  if (to === (from + 1) % n) {
    return order[(at + 1) % n];
  }
  if (to === (from - 1 + n) % n) {
    return order[(at - 1 + n) % n];
  }
  return otherID;
}

function swapInOrder(a, b) {
  var i = order.indexOf(a);
  var j = order.indexOf(b);
  if (i === -1 || j === -1 || i === j) {
    return;
  }
  order[i] = b;
  order[j] = a;
}

// Hyprland's rollnext (dir = 1) / rollprev (dir = -1), MasterAlgorithm.cpp:
// the first (rollnext) or last (rollprev) slave takes the old master's place.
// The old master is the focused window if it is a master, else the first
// master, and it moves to the end (rollnext) or front (rollprev) of the
// slaves. With one master this rotates the whole order by one.
function roll(state, focusedID, dir) {
  var masters = order.slice(0, Math.min(state.mainPaneCount, order.length));
  var slaves = order.slice(masters.length);
  if (slaves.length === 0) {
    return state;
  }
  var at = Math.max(masters.indexOf(focusedID), 0);
  var oldMaster = masters[at];
  if (dir > 0) {
    masters[at] = slaves.shift();
    slaves.push(oldMaster);
  } else {
    masters[at] = slaves.pop();
    slaves.unshift(oldMaster);
  }
  order = masters.concat(slaves);
  return Object.assign({}, state);
}

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
      command3: {
        description: "Roll next (Hyprland layoutmsg rollnext)",
        updateState: function (state, focusedID) {
          return roll(state, focusedID, 1);
        },
      },
      command4: {
        description: "Roll previous (Hyprland layoutmsg rollprev)",
        updateState: function (state, focusedID) {
          return roll(state, focusedID, -1);
        },
      },
    },
    updateWithChange: function (change, state) {
      if (change.change === "focus_changed") {
        focusedWindowID = change.windowID;
      }
      if (change.change === "window_swap") {
        swapInOrder(change.windowID, translateSwap(change.windowID, change.otherWindowID));
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
      var ids = reconcile(
        windows.map(function (w) {
          return w.id;
        }),
      );
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
