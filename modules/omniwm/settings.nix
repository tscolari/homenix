# The OmniWM settings.toml content, as a Nix attrset.
#
# ./defaults.toml is a VERBATIM canonical settings file, produced by running
# OmniWM v0.6.3 once against an empty config directory. It is the baseline, and
# this file layers the Hyprland-derived overrides on top of it.
#
# Why a committed baseline rather than just the keys we care about: OmniWM's TOML
# schema (Core/Config/CanonicalTOMLConfig.swift) decodes every table with
# `decode`, not `decodeIfPresent`, so a partial file does not merge over defaults
# — it fails to parse. On a parse failure OmniWM discards the file, rewrites it
# with defaults and only logs about it, so an incomplete config fails silently
# rather than loudly. See OMNI-WM-PROJECT.md.
#
# ⚠️ Float-typed keys must be written as Nix floats (16.0, not 16). An integer
# here becomes a TOML integer, which will not decode into a Swift Double.
{ lib }:

let
  defaults = builtins.fromTOML (builtins.readFile ./defaults.toml);

  # Gap between tiled windows, and between windows and the screen edge.
  #
  # Hyprland is gaps_in = 1 / gaps_out = 1 — a literal one pixel, effectively
  # invisible. That is faithful but reads as "no gaps at all" on a large display,
  # so this follows the AeroSpace module's 8 instead. Set to 1.0 for strict
  # Hyprland fidelity.
  gapSize = 8.0;

  # Height of the sketchybar bar, mirrored from
  # configs/sketchybar-omniwm/sketchybarrc (`--bar height=26`). Kept here so the
  # top gap below stays correct; change it in both places.
  sketchybarHeight = 26.0;

  # macOS does not shrink the display's visibleFrame for either bar — OmniWM
  # reports visibleFrame == frame — so nothing reserves this space for us.
  # workspaceBar.reserveLayoutSpace looks like it should, but was measured to be
  # a no-op here (tiled windows stayed at y = outer.top with it both on and off),
  # so the top inset has to be spelled out as an outer gap.
  #
  # Both bars share the menu bar row rather than stacking, so this reserves one
  # bar height, not two. OmniWM's own bar (24) is shorter than sketchybar (26),
  # so sketchybar's height is what has to be cleared.
  gapTop = sketchybarHeight + gapSize;

  # Hyprland pins workspaces 1-10 per monitor via lib/monitors.nix; OmniWM only
  # hotkeys nine of them. The first seven ids are OmniWM's own built-in defaults
  # (hard-coded upstream, not randomly generated, so they are stable across
  # installs); 8 and 9 are ours and must stay put once committed.
  workspaceIds = [
    "AD36F001-C57E-41A5-AC1D-DF5249D007F0"
    "454CECD4-5E9D-4ED1-95D7-979D48817F5F"
    "BEB842B5-E894-4791-9FD1-397C3CDD3538"
    "248AA883-2261-4D45-943C-79C0E46A232B"
    "8B8C45D6-CE9E-41D9-BD50-BE4989D5E3DE"
    "5953F2BF-A378-4266-91B2-287174C4FA4D"
    "A7D5E104-6985-4516-8ED5-07F144F2A33D"
    "BBB93F01-94F5-4FBD-976C-C73CAB28E26F"
    "C059A123-F845-434D-BF11-8208E694FB5E"
  ];

  workspaces = lib.imap0 (i: id: {
    inherit id;
    name = toString (i + 1);
    layoutType = "dwindle";
    # Hyprland's monitor pinning lives in lib/monitors.nix and is per-machine.
    # "main" keeps every workspace on the primary display until the monitor
    # story is revisited (see Deferred in OMNI-WM-PROJECT.md).
    monitorAssignment.type = "main";
  }) workspaceIds;

  overrides = {
    general = {
      # configs/hypr/settings.lua general.layout, and the dwindle override in
      # every lib/monitors.nix preset.
      defaultLayoutType = "dwindle";
      hotkeysEnabled = true;
      # Required before omniwmctl works at all, and ./skhd.nix shells out to it.
      ipcEnabled = true;
      animationsEnabled = true;
      # Nix owns the version; an in-app updater would fight it.
      updateChecksEnabled = false;
    };

    focus = {
      # settings.lua input.follow_mouse = 1
      followsMouse = true;
      followsWindowToMonitor = true;
    };

    mouseWarp = {
      # settings.lua cursor.warp_on_change_workspace = 2, and the AeroSpace
      # module's on-focused-monitor-changed = "move-mouse monitor-lazy-center".
      enabled = true;
    };

    # decorations.lua general.gaps_in / gaps_out — see gapSize above for why
    # this is 8 rather than Hyprland's literal 1.
    #
    # The top edge is special: it has to clear the menu bar row that sketchybar
    # and OmniWM's workspace bar share, the same way the AeroSpace module's
    # outer.top = 30 reserved room for sketchybar alone.
    gaps = {
      size = gapSize;
      outer = {
        left = gapSize;
        right = gapSize;
        top = gapTop;
        bottom = gapSize;
      };
    };

    # decorations.lua general.border_size = 3, col.active_border = color6.
    #
    # Hyprland resolves that colour at runtime from wallust / the current theme;
    # OmniWM cannot, because its colours live in this Nix-generated file. Pinned
    # to kanagawa's $activeBorderColor (#dcd7ba) — the same value
    # themes/kanagawa/hyprland.conf and themes/kanagawa/jankyborders.sh use — so
    # it at least matches the repo's default theme. See Deferred for making this
    # follow theme switches.
    borders = {
      enabled = true;
      width = 3.0;
      color = {
        red = 0.8627450980392157; # 0xdc
        green = 0.8431372549019608; # 0xd7
        blue = 0.7294117647058823; # 0xba
        alpha = 1.0;
      };
    };

    dwindle = {
      # settings.lua dwindle.preserve_split = true has no exact counterpart;
      # moveToRootStable is the nearest behaviour.
      moveToRootStable = true;
      smartSplit = false;
      useGlobalGaps = true;
    };

    gestures = {
      # settings.lua: hl.gesture({ fingers = 3, direction = "horizontal",
      # action = "workspace" }) and gestures.workspace_swipe_invert = true.
      workspaceSwipeEnabled = true;
      workspaceSwipeAxis = "horizontal";
      workspaceSwipeFingerCount = 3;
      fingerCount = 3;
      invertDirection = true;
      # Recovers bindings.lua's SUPER+mouse:272 / :273 drag-resize and
      # SUPER+mouse_up / mouse_down workspace scroll, which are gestures in
      # OmniWM rather than bindable hotkeys.
      mouseMoveModifierKey = "command";
      mouseResizeModifierKey = "command";
      scrollModifierKey = "command";
    };

    # Workspace half of what waybar did; ./sketchybar.nix supplies the status
    # half. Both share the menu bar row, so they divide it up:
    #
    #   left:   sketchybar Apple menu, then the focused-window title
    #   center: this bar
    #   right:  sketchybar status cluster
    #
    # xOffset stays 0, i.e. the true screen centre, and that is deliberate.
    #
    # The bar is centre-anchored with no way to change that: WorkspaceBarGeometry
    # computes `x = monitor.frame.midX - width / 2` and then merely adds xOffset,
    # and neither the global settings nor the per-monitor overrides
    # (MonitorBarSettings) expose any alignment or anchor field. Its rendered
    # width also changes at runtime — as workspaces appear and disappear under
    # hideEmptyWorkspaces below, and as the app icons inside each chip come and
    # go — so it grows and shrinks about its centre by design.
    #
    # An offset bar therefore visibly slides around as that width changes, and no
    # static offset can hold an edge still. Leaving it centred makes the symmetric
    # growth read as intentional, and keeps the setting display-independent: an
    # offset tuned for a 5120px monitor is wrong on a laptop, and there is no
    # clamping, so a large enough value pushes the bar off-screen entirely.
    #
    # If you do want it off-centre on a particular machine anyway:
    #   programs.homenix.omniwm.extraSettings.workspaceBar.xOffset = -1234.0;
    #
    # reserveLayoutSpace is left off deliberately: it was measured to have no
    # effect on where tiled windows start, so gapTop above does the reserving.
    workspaceBar = {
      enabled = true;
      position = "overlappingMenuBar";
      xOffset = 0.0;
      reserveLayoutSpace = false;
      showLabels = true;

      # Show a workspace only while it holds windows, plus whichever one is
      # active. Keeps the bar down to what is actually in use, the way the
      # sketchybar workspace items used to behave.
      #
      # ⚠️ Not quite the old sketchybar behaviour, because OmniWM cannot express
      # it. That config had PERSISTENT_SPACES=4: workspaces 1-4 always drawn,
      # 5-9 only while occupied. OmniWM's filter is all-or-nothing —
      # WorkspaceBarDataSource keeps `hasBarOccupancy || isActive` — and a
      # workspace entry has no "always show" flag, so there is no floor.
      #
      # Declaring only five workspaces would give the floor but lose the
      # overflow: both switchWorkspace and moveWindowToWorkspace resolve names
      # with `createIfMissing: false`, so workspaces 6-9 would stop existing and
      # Cmd+6..9 would silently do nothing. All nine stay declared instead.
      hideEmptyWorkspaces = true;
    };

    # Hyprland autostarts cliphist; OmniWM has history built in, reachable from
    # the command palette.
    clipboard.historyEnabled = true;

    # configs/hypr/scripts/dropdown_terminal.sh exists but is bound to no key,
    # so there is nothing to migrate. Off by default here, unlike OmniWM's own
    # default, to keep the surface close to Hyprland's.
    quakeTerminal.enabled = false;
  };

in

lib.recursiveUpdate defaults overrides
// {
  # recursiveUpdate replaces lists wholesale, which is what we want for these:
  # each is a complete, ordered replacement rather than a merge.
  hotkeys = import ./hotkeys.nix { inherit lib; };
  inherit workspaces;
}
