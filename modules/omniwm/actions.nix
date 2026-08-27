# Every assignable OmniWM hotkey action id, in ActionCatalog source order.
#
# DERIVED FROM OmniWM v0.6.3 — regenerate on every version bump. The list must be
# exhaustive and exact: HotkeyBindingRegistry.resolve() walks every default binding
# and throws `missingActionID` when the config omits one, `unknownActionID` for an
# id this build does not have, and `unassignableActionID` for an id whose spec is
# marked `.unassignable`. A stale list is a hard startup error, not a warning.
#
# To regenerate:
#   grep -o 'id: "[^"]*"' Sources/OmniWM/Core/Input/ActionCatalog.swift
# then expand the six interpolated `\(idx)` families below and drop any spec
# carrying `visibility: .unassignable`.
#
# Excluded as unassignable at v0.6.3: consumeOrExpelWindowLeft,
# consumeOrExpelWindowRight. (Both WERE assignable in v0.6.2 — a config that binds
# them is rejected by v0.6.3.)
{ lib }:

let
  # "focusColumn" 0 8 -> [ "focusColumn.0" ... "focusColumn.8" ]
  indexed =
    name: lo: hi:
    map (i: "${name}.${toString i}") (lib.range lo hi);
in

lib.concatLists [
  (indexed "switchWorkspace" 0 8)
  (indexed "moveToWorkspace" 0 8)
  [
    "workspaceBackAndForth"
    "switchWorkspace.next"
    "switchWorkspace.previous"
    "focus.left"
    "focus.down"
    "focus.up"
    "focus.right"
    "focusPrevious"
    "focusDownOrLeft"
    "focusUpOrRight"
    "focusWindowTop"
    "focusWindowBottom"
    "focusWindowDownOrTop"
    "focusWindowUpOrBottom"
    "focusWindowOrWorkspaceDown"
    "focusWindowOrWorkspaceUp"
    "centerColumn"
    "centerVisibleColumns"
    "moveWindowToWorkspaceUp"
    "moveWindowToWorkspaceDown"
    "moveColumnToWorkspaceUp"
    "moveColumnToWorkspaceDown"
  ]
  (indexed "moveColumnToWorkspace" 0 8)
  [
    "move.left"
    "move.down"
    "move.up"
    "move.right"
    "moveWindowDown"
    "moveWindowUp"
    "moveWindowDownOrToWorkspaceDown"
    "moveWindowUpOrToWorkspaceUp"
    "consumeWindowIntoColumn"
    "expelWindowFromColumn"
    "focusMonitorNext"
    "focusMonitorPrevious"
    "focusMonitorLast"
    "moveWorkspaceToMonitor.left"
    "moveWorkspaceToMonitor.right"
    "moveWorkspaceToMonitor.up"
    "moveWorkspaceToMonitor.down"
    "moveWindowToMonitor.left"
    "moveWindowToMonitor.right"
    "moveWindowToMonitor.up"
    "moveWindowToMonitor.down"
    "toggleFullscreen"
    "toggleNativeFullscreen"
    "moveColumn.left"
    "moveColumn.right"
    "moveColumn.up"
    "moveColumn.down"
    "moveColumnToFirst"
    "moveColumnToLast"
    "toggleColumnTabbed"
    "focusColumnFirst"
    "focusColumnLast"
  ]
  (indexed "focusColumn" 0 8)
  (indexed "focusWindowInColumn" 1 9)
  (indexed "moveColumnToIndex" 1 9)
  [
    "cycleSizeForward"
    "cycleSizeBackward"
    "cycleWindowPrimarySpanForward"
    "cycleWindowPrimarySpanBackward"
    "cycleWindowSecondarySpanForward"
    "cycleWindowSecondarySpanBackward"
    "toggleContainerFullPrimarySpan"
    "expandContainerToAvailablePrimarySpan"
    "resetWindowSecondarySpan"
    "setContainerPrimarySpan.decrease10Percent"
    "setContainerPrimarySpan.increase10Percent"
    "setWindowPrimarySpan.decrease10Percent"
    "setWindowPrimarySpan.increase10Percent"
    "setWindowSecondarySpan.decrease10Percent"
    "setWindowSecondarySpan.increase10Percent"
    "balanceSizes"
    "moveToRoot"
    "toggleSplit"
    "swapSplit"
    "resizeGrow.horizontal"
    "resizeGrow.vertical"
    "resizeShrink.horizontal"
    "resizeShrink.vertical"
    "resizeFocusedWindow.grow"
    "resizeFocusedWindow.shrink"
    "preselect.left"
    "preselect.right"
    "preselect.up"
    "preselect.down"
    "preselectClear"
    "openCommandPalette"
    "raiseAllFloatingWindows"
    "rescueOffscreenWindows"
    "toggleFocusedWindowFloating"
    "assignFocusedWindowToScratchpad"
    "toggleScratchpadWindow"
    "openMenuAnywhere"
    "toggleWorkspaceBarVisibility"
    "toggleHiddenBarPanel"
    "toggleQuakeTerminal"
    "toggleWorkspaceLayout"
    "toggleOverview"
    "toggleSystemStats"
  ]
]
