# Hyprland -> OmniWM keybinding migration.
#
# Source of truth is configs/hypr/bindings.lua. modules/aerospace/default.nix
# supplies the macOS modifier convention already in use here, and where the two
# disagree Hyprland wins.
#
# Modifier convention: Hyprland SUPER -> Command; Option = the focus axis,
# Control = the move axis. (Plain Command+H/L are avoided: macOS binds Cmd+H to
# Hide and browsers bind Cmd+L to the address bar.)
#
# OmniWM has no exec/spawn action, so every shell binding from bindings.lua lives
# in ./skhd.nix instead. See OMNI-WM-PROJECT.md for the full migration table,
# including the Hyprland bindings that have no OmniWM equivalent.
{ lib }:

let
  actionIds = import ./actions.nix { inherit lib; };

  # Hyprland SUPER+<n> / SUPER+SHIFT+<n>. Note OmniWM's workspace action ids are
  # ZERO-based while the keys they sit on are one-based: switchWorkspace.0 is
  # workspace "1". Hyprland's tenth workspace has no OmniWM counterpart.
  workspaceBindings = lib.listToAttrs (
    lib.concatMap (i: [
      (lib.nameValuePair "switchWorkspace.${toString i}" "Command+${toString (i + 1)}")
      (lib.nameValuePair "moveToWorkspace.${toString i}" "Command+Shift+${toString (i + 1)}")
    ]) (lib.range 0 8)
  );

  # Ported from Hyprland, one-to-one.
  migrated = {
    # SUPER+ALT+hjkl -- focus
    "focus.left" = "Command+Option+H";
    "focus.down" = "Command+Option+J";
    "focus.up" = "Command+Option+K";
    "focus.right" = "Command+Option+L";

    # SUPER+CTRL+hjkl -- move window
    "move.left" = "Command+Control+H";
    "move.down" = "Command+Control+J";
    "move.up" = "Command+Control+K";
    "move.right" = "Command+Control+L";

    # SUPER+SHIFT+[ / ] -- move window to previous / next workspace
    "moveWindowToWorkspaceUp" = "Command+Shift+Left Bracket";
    "moveWindowToWorkspaceDown" = "Command+Shift+Right Bracket";

    # SUPER+tab / SUPER+SHIFT+tab -- cycle workspaces.
    # Command+Tab alone is the macOS app switcher, hence the extra Option.
    "switchWorkspace.next" = "Command+Option+Tab";
    "switchWorkspace.previous" = "Command+Option+Shift+Tab";

    # Hyprland gets this implicitly from binds.workspace_back_and_forth = true;
    # OmniWM needs a real chord.
    "workspaceBackAndForth" = "Command+Option+Grave";

    # SUPER+CTRL+F fullscreen, SUPER+ALT+F maximize
    "toggleFullscreen" = "Command+Control+F";
    "toggleNativeFullscreen" = "Command+Option+F";

    # SUPER+SHIFT+I togglesplit (dwindle)
    "toggleSplit" = "Command+Shift+I";

    # SUPER+CTRL+RETURN swapwithmaster -- moveToRoot is the dwindle analogue
    "moveToRoot" = "Command+Control+Return";

    # SUPER+L change layout. Command+Shift+L rather than Command+L, which
    # browsers take for the address bar.
    "toggleWorkspaceLayout" = "Command+Shift+L";

    # SUPER+ALT+SPACE. Hyprland floats every window on the workspace; OmniWM
    # only offers the focused one.
    "toggleFocusedWindowFloating" = "Command+Option+Space";

    # SUPER+grave -- hyprexpo overview
    "toggleOverview" = "Command+Grave";

    # SUPER+CTRL+ALT+B -- waybar toggle
    "toggleWorkspaceBarVisibility" = "Command+Control+Option+B";

    # ALT+tab window cycling. Option+Tab is unclaimed on macOS, where Command+Tab
    # switches applications rather than windows.
    "focusPrevious" = "Option+Tab";

    # SUPER+SHIFT+arrows -- resize by 50px in Hyprland; OmniWM resizes by axis
    # rather than by direction, so the left/right pair collapses onto one axis.
    "resizeGrow.horizontal" = "Command+Shift+Right Arrow";
    "resizeShrink.horizontal" = "Command+Shift+Left Arrow";
    "resizeGrow.vertical" = "Command+Shift+Down Arrow";
    "resizeShrink.vertical" = "Command+Shift+Up Arrow";
  };

  # No Hyprland original -- OmniWM capabilities worth having. Kept separate so a
  # later reader does not go hunting through bindings.lua for the source.
  additions = {
    # Dwindle housekeeping, no Hyprland equivalent bound today.
    "balanceSizes" = "Command+Control+B";
    "swapSplit" = "Command+Control+Shift+S";

    # Hyprland addressed monitors indirectly, by pinning workspaces to outputs
    # (lib/monitors.nix). OmniWM exposes them directly.
    "focusMonitorPrevious" = "Command+Option+Left Arrow";
    "focusMonitorNext" = "Command+Option+Right Arrow";
    "moveWindowToMonitor.left" = "Command+Control+Option+H";
    "moveWindowToMonitor.right" = "Command+Control+Option+L";

    # Command+Option+Space would have been the natural home, but
    # toggleFocusedWindowFloating has the stronger claim to it (SUPER+ALT+SPACE).
    "openCommandPalette" = "Command+Control+Space";
    "raiseAllFloatingWindows" = "Command+Control+R";
  };

  assigned = workspaceBindings // migrated // additions;

  # Anything we do not bind must still be listed, as "Unassigned" -- OmniWM
  # rejects a config that omits a known action id.
  merged = (lib.genAttrs actionIds (_: "Unassigned")) // assigned;

  # A typo'd id would otherwise surface as a runtime `unknownActionID` from
  # OmniWM long after the build succeeded. Catch it here instead.
  unknownIds = lib.subtractLists actionIds (lib.attrNames assigned);

  # OmniWM detects chord conflicts at runtime, but a build-time failure names the
  # culprits and is far cheaper to debug.
  chords = lib.attrValues assigned;
  duplicateChords = lib.unique (lib.filter (c: lib.count (x: x == c) chords > 1) chords);

in

lib.throwIf (unknownIds != [ ])
  "omniwm: hotkey ids not present in OmniWM's action catalog (stale actions.nix, or a typo): ${lib.concatStringsSep ", " unknownIds}"
  (
    lib.throwIf (duplicateChords != [ ])
      "omniwm: the same chord is bound to more than one action: ${lib.concatStringsSep ", " duplicateChords}"
      # Emitted in ActionCatalog order so the generated TOML diffs cleanly against
      # a settings.toml that OmniWM itself has written.
      (
        map (id: {
          inherit id;
          binding = merged.${id};
        }) actionIds
      )
  )
