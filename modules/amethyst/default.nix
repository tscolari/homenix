# Amethyst — Hyprland configuration (configs/hypr) ported to Amethyst.
#
# configs/hypr is the source of truth; the OmniWM and AeroSpace modules are
# earlier, looser ports. Where Amethyst can express a Hyprland behaviour it is
# carried over, everything else is listed at the bottom of this file.
#
# Layout: Hyprland's master layout with orientation = center is not one of
# Amethyst's native layouts (3column-middle is close but differs, see
# configs/amethyst/hypr-master.js), so it ships as a custom JavaScript layout.
#
# Workspaces are native macOS desktops (Spaces). Amethyst cannot switch between
# them itself, so "Switch to Desktop N" is bound through the system symbolic
# hotkeys below, and Amethyst only throws windows between them.
{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.amethyst;

  yaml = pkgs.formats.yaml { };

  # configs/hypr/decorations.lua: general.gaps_in / gaps_out / border_size.
  gapsIn = 0;
  gapsOut = 5;
  borderSize = 5;

  # Hyprland's border reserves space inside the tile (the border decoration is
  # `reserved`), so window content sits gaps + border_size from its neighbour
  # and from the screen edge: 2 * (1 + 3) = 8px between windows, 1 + 3 = 4px at
  # the edges. jankyborders draws outside the window frame instead, so the
  # border has to be counted into Amethyst's margins for the same spacing.
  innerGap = gapsIn + borderSize;
  outerGap = gapsOut + borderSize;

  # configs/hypr/settings.lua: master.mfact.
  mfact = 0.4;

  # configs/hypr/bindings.lua: SUPER+SHIFT+arrows resize by 50px.
  resizeStep = 50;

  # Height of the sketchybar bar, mirrored from configs/sketchybar/sketchybarrc
  # (`--bar height=26`), reserved the way Hyprland reserves waybar's exclusive
  # zone. The menu bar is auto-hidden on these machines, so the screen frame
  # Amethyst starts from already reaches the top edge.
  barHeight = if config.programs.homenix.sketchybar.enable then 26 else 0;

  layoutKey = "hypr-master";

  layoutFile = pkgs.writeText "${layoutKey}.js" ''
    var HYPR = ${builtins.toJSON { inherit mfact resizeStep; }};

    ${builtins.readFile ../../configs/amethyst/hypr-master.js}
  '';

  focusDirection = ../../configs/amethyst/focus-direction.js;

  # Hyprland SUPER maps to Command throughout, with Option as the focus axis
  # and Control as the move axis, the same convention as modules/omniwm.
  # Amethyst binds every command to one of four named modifier sets.
  mods = {
    mod1 = [
      "command"
      "option"
    ];
    mod2 = [
      "command"
      "control"
    ];
    mod3 = [
      "command"
      "shift"
    ];
  };

  bind = mod: key: { inherit mod key; };

  # Ported from configs/hypr/bindings.lua.
  commands = {
    # SUPER+ALT+hjkl (focus) is not here: Amethyst can only focus by window
    # order, so skhd runs configs/amethyst/focus-direction.js instead.

    # SUPER+CTRL+h / l -- move window. In Hyprland's master layout this swaps
    # with the neighbour, which is what swap-ccw / swap-cw do along the window
    # order. j / k and SUPER+SHIFT+CTRL+hjkl (swap) have no second command to
    # bind to.
    swap-ccw = bind "mod2" "h";
    swap-cw = bind "mod2" "l";

    # SUPER+CTRL+RETURN -- swapwithmaster + focusmaster. Focus stays on the
    # swapped window, which is now the master.
    swap-main = bind "mod2" "enter";

    # SUPER+I addmaster / SUPER+CTRL+D removemaster. Command+I alone is italic
    # or Get Info in most apps, so addmaster moves to Command+Shift+I, which is
    # free here: Hyprland put togglesplit there, and Amethyst's bsp has no
    # equivalent.
    increase-main = bind "mod3" "i";
    decrease-main = bind "mod2" "d";

    # SUPER+SHIFT+arrows -- resizeactive by 50px. The layout applies
    # Hyprland's own rules: left / right change mfact, signed by the focused
    # window's column, and up / down change the focused window's share of its
    # column.
    shrink-main = bind "mod3" "left";
    expand-main = bind "mod3" "right";
    command1 = bind "mod3" "down";
    command2 = bind "mod3" "up";

    # SUPER+L -- toggle master / dwindle. bsp is Amethyst's dwindle. Selecting
    # the active layout again returns to the previous one, which makes this a
    # toggle. Command+Shift+L rather than Command+L, which browsers take for
    # the address bar (same as modules/omniwm).
    "select-bsp-layout" = bind "mod3" "l";

    # SUPER+ALT+F -- maximize (fullscreen 1). Also a toggle, as above.
    # SUPER+CTRL+F (real fullscreen) is macOS's own Control+Command+F.
    "select-fullscreen-layout" = bind "mod1" "f";

    # SUPER+ALT+SPACE -- Hyprland floats every window on the workspace;
    # Amethyst only toggles the focused one.
    toggle-float = bind "mod1" "space";

    # SUPER+SHIFT+[ / ] -- move window to previous / next workspace.
    throw-space-left = bind "mod3" "[";
    throw-space-right = bind "mod3" "]";
  }
  # SUPER+SHIFT+1..9 -- move window to workspace N and follow it
  # (follow-space-thrown-windows). Hyprland's tenth workspace is left out, as in
  # modules/omniwm and modules/aerospace.
  // listToAttrs (
    map (n: nameValuePair "throw-space-${toString n}" (bind "mod3" (toString n))) (range 1 9)
  );

  # Every command Amethyst registers (HotKeyManager.swift, v0.25.0). Once mod1 /
  # mod2 are customised, Amethyst re-applies its own default bindings to any
  # command missing from the file using *these* modifiers, so every unused one
  # is switched off explicitly.
  allCommands = [
    "cycle-layout"
    "cycle-layout-backward"
    "shrink-main"
    "expand-main"
    "increase-main"
    "decrease-main"
    "increase-window-max-count"
    "decrease-window-max-count"
    "toggle-new-windows-to-main"
    "command1"
    "command2"
    "command3"
    "command4"
    "focus-ccw"
    "focus-cw"
    "focus-main"
    "focus-screen-ccw"
    "focus-screen-cw"
    "swap-screen-ccw"
    "swap-screen-cw"
    "swap-ccw"
    "swap-cw"
    "swap-main"
    "display-current-layout"
    "throw-space-left"
    "throw-space-right"
    "toggle-float"
    "toggle-tiling"
    "enable-tiling"
    "disable-tiling"
    "reevaluate-windows"
    "toggle-focus-follows-mouse"
    "relaunch-amethyst"
  ]
  ++ concatMap (n: [
    "focus-screen-${toString n}"
    "throw-screen-${toString n}"
  ]) (range 1 5)
  ++ map (n: "throw-space-${toString n}") (range 1 16)
  ++ map (key: "select-${key}-layout") [
    "tall"
    "tall-right"
    "wide"
    "two-pane"
    "two-pane-right"
    "middle-wide"
    "3column-left"
    "3column-right"
    "4column-left"
    "4column-right"
    "column"
    "row"
    "floating"
    "widescreen-tall"
    "widescreen-tall-right"
    "bsp"
    "fullscreen"
    layoutKey
  ];

  disabledCommands = genAttrs (subtractLists (attrNames commands) allCommands) (_: false);

  settings = {
    # SUPER+L toggles between these two; fullscreen backs SUPER+ALT+F.
    layouts = [
      layoutKey
      "bsp"
      "fullscreen"
    ];

    # Gaps. Amethyst insets the screen by half the margin and every window by
    # half again, so window-margin-size = 2 * innerGap leaves innerGap on each
    # side of every window (2 * innerGap between neighbours). The screen edge
    # then sits 2 * innerGap away, and the padding corrects that to outerGap,
    # going negative when outerGap < 2 * innerGap. The top edge has no gap at
    # all: windows start right under the bar.
    window-margins = true;
    smart-window-margins = false;
    window-margin-size = 2 * innerGap;
    screen-padding-top = barHeight - 2 * innerGap;
    screen-padding-bottom = outerGap - 2 * innerGap;
    screen-padding-left = outerGap - 2 * innerGap;
    screen-padding-right = outerGap - 2 * innerGap;
    ignore-menu-bar = false;

    # master.new_status = master, new_on_top = true.
    new-windows-to-main = true;
    follow-space-thrown-windows = true;

    # input.follow_mouse = 1, cursor.no_warps = true.
    focus-follows-mouse = true;
    mouse-follows-focus = false;

    # SUPER+LMB drag / SUPER+RMB resize and general.resize_on_border. macOS
    # has no modifier-drag, so these act on plain drags.
    mouse-swaps-windows = true;
    mouse-resizes-windows = true;

    # Hyprland's float rules (window_rules.lua), for the macOS apps that have
    # an equivalent. Small dialogs float on their own via float-small-windows,
    # which covers the popup / dialogue rules.
    floating-is-blacklist = true;
    floating = [
      "us.zoom.xos" # Zoom
      "com.apple.calculator" # Calculator
      "io.mpv" # mpv
      "com.apple.systempreferences" # settings tag
      "com.apple.ActivityMonitor" # viewer tag: system monitor
      "com.apple.Preview" # viewer tag: evince / eog
    ];
    float-small-windows = true;

    # Hyprland only notifies on a layout change (scripts/change_layout.sh).
    enables-layout-hud = true;
    enables-layout-hud-on-space-change = false;

    restore-layouts-on-launch = true;
  }
  // mods
  // disabledCommands
  // commands;

  # Native macOS shortcuts (com.apple.symbolichotkeys): "Switch to Desktop N"
  # (ids 118..), "Move left / right a space" (79 / 81), Mission Control (32)
  # and "Move focus to next window" (27). Parameters are (character, virtual
  # key code, modifier mask); 65535 means no character.
  commandMask = 1048576;
  optionMask = 524288;
  shiftMask = 131072;
  digitKeyCodes = [
    18
    19
    20
    21
    23
    22
    26
    28
    25
  ];
  symbolicHotkeys =
    imap1 (n: keyCode: {
      # SUPER+1..9 -- workspace N.
      id = 117 + n;
      inherit keyCode;
      modifiers = commandMask;
    }) digitKeyCodes
    ++ [
      # SUPER+TAB / SUPER+SHIFT+TAB -- next / previous workspace. Command+Tab
      # alone is the macOS app switcher, hence the extra Option (same as
      # modules/omniwm).
      {
        id = 81;
        keyCode = 48;
        modifiers = commandMask + optionMask;
      }
      {
        id = 79;
        keyCode = 48;
        modifiers = commandMask + optionMask + shiftMask;
      }

      # SUPER+grave -- workspace overview (hyprexpo) -> Mission Control. This
      # has to be the system shortcut: WindowServer keeps Command+` for itself,
      # so skhd never sees it. Ctrl+Up, the shortcut it replaces, comes back
      # through skhd.
      {
        id = 32;
        char = 96;
        keyCode = 50;
        modifiers = commandMask;
      }
      # "Move focus to next window" sits on Command+` by default. Switched off
      # so the two shortcuts don't share a chord.
      {
        id = 27;
        enabled = false;
        char = 96;
        keyCode = 50;
        modifiers = commandMask;
      }
    ];

  hotkeyPlist =
    hotkey:
    "<dict><key>enabled</key><${
      boolToString (hotkey.enabled or true)
    }/><key>value</key><dict><key>parameters</key><array><integer>${
      toString (hotkey.char or 65535)
    }</integer><integer>${toString hotkey.keyCode}</integer><integer>${toString hotkey.modifiers}</integer></array><key>type</key><string>standard</string></dict></dict>";

  restartAmethyst = ''
    if /bin/launchctl print "gui/$UID/org.nix-community.home.amethyst" >/dev/null 2>&1; then
      /bin/launchctl kickstart -k "gui/$UID/org.nix-community.home.amethyst" >/dev/null 2>&1 || true
    fi
  '';

in
{
  options.programs.homenix.amethyst = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Amethyst window manager configuration (macOS)";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../../pkgs/amethyst { };
      defaultText = literalExpression "pkgs.callPackage ../../pkgs/amethyst { }";
      description = ''
        Amethyst package to use. Defaults to this repo's own derivation, since
        Amethyst is not in nixpkgs.
      '';
    };

    spaceHotkeys = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Bind the macOS "Switch to Desktop 1-9" shortcuts to Command+1..9,
        "Move left / right a space" to Command+Option+(Shift+)Tab and Mission
        Control to Command+` (turning off "Move focus to next window", which
        shares it), and turn off "Automatically rearrange Spaces based on most
        recent use" so desktop numbers stay put. Amethyst cannot switch
        desktops on its own.

        The desktops themselves still have to be created once in Mission
        Control.
      '';
    };

    extraSettings = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''
        {
          focus-follows-mouse = false;
          floating = [ "com.apple.finder" ];
        }
      '';
      description = "Keys merged over the generated amethyst.yml.";
    };
  };

  config = mkIf (config.programs.homenix.enable && cfg.enable && pkgs.stdenv.isDarwin) {
    assertions = [
      {
        assertion = !config.programs.homenix.omniwm.enable && !config.programs.homenix.aerospace.enable;
        message = ''
          programs.homenix.amethyst is enabled together with programs.homenix.omniwm
          or programs.homenix.aerospace. They are all macOS window managers and will
          fight over every window. Enable only one of them.
        '';
      }
      (lib.hm.assertions.assertPlatform "programs.homenix.amethyst" pkgs lib.platforms.darwin)
    ];

    programs.homenix.jankyborders = {
      enable = mkDefault true;
      # configs/hypr/decorations.lua: general.border_size.
      width = mkDefault (borderSize * 1.0);
    };

    programs.homenix.sketchybar = {
      enable = mkDefault true;
      workspaces = {
        enable = mkDefault true;
        source = mkDefault "spaces";
      };
    };

    # Exec bindings Amethyst cannot express itself; see modules/skhd.
    programs.homenix.skhd = {
      enable = mkDefault true;
      extraBindings = ''
        # SUPER+ALT+hjkl -- directional focus (Hyprland movefocus).
        cmd + alt - h : osascript -l JavaScript ${focusDirection} left
        cmd + alt - j : osascript -l JavaScript ${focusDirection} down
        cmd + alt - k : osascript -l JavaScript ${focusDirection} up
        cmd + alt - l : osascript -l JavaScript ${focusDirection} right

        # SUPER+SHIFT+Q -- terminate the focused window's process
        # (bindings.lua: scripts/kill_focus.sh), via the frontmost app's pid.
        cmd + shift - q : pid=$(lsappinfo info -only pid "$(lsappinfo front)" | awk -F= '/pid/ { print $2 }') && [ -n "$pid" ] && kill -9 "$pid"

        # Ctrl+Up -- Mission Control's default shortcut, which the system
        # shortcut now gives to Command+` (SUPER+grave, see symbolicHotkeys).
        ctrl - up : open -a "Mission Control"

        # SUPER+CTRL+ALT+B -- toggle the bar (bindings.lua: pkill -SIGUSR1 waybar).
        # Unlike waybar, the space Amethyst reserves for it stays.
        cmd + ctrl + alt - b : sketchybar --bar hidden=toggle
      '';
    };

    home.packages = [ cfg.package ];

    # Program rather than ProgramArguments: it is a bundled app, launched by its
    # real executable, the same way modules/omniwm runs OmniWM.
    launchd.agents.amethyst = {
      enable = true;
      config = {
        Program = "${cfg.package}/Applications/Amethyst.app/Contents/MacOS/Amethyst";
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/amethyst/amethyst.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/amethyst/amethyst.err.log";
      };
    };

    # Amethyst only reads its config and layouts at launch.
    xdg.configFile."amethyst/amethyst.yml" = {
      source = yaml.generate "amethyst.yml" (recursiveUpdate settings cfg.extraSettings);
      onChange = restartAmethyst;
    };

    home.file."Library/Application Support/Amethyst/Layouts/${layoutKey}.js" = {
      source = layoutFile;
      onChange = restartAmethyst;
    };

    # Nix owns the version; Sparkle cannot replace a bundle in the store.
    targets.darwin.defaults."com.amethyst.Amethyst".SUEnableAutomaticChecks = false;

    # Command+Option+H is SUPER+ALT+h (focus left), but it is also the "Hide
    # Others" menu shortcut in every app. When the chord reaches the app
    # instead of skhd (secure input, a paused event tap), every other window
    # vanishes. Moving Hide Others to Command+Option+Control+Shift+H makes a
    # stray press harmless. -dict-add keeps any other menu shortcut overrides,
    # and apps read this at launch, so running ones need a relaunch.
    home.activation.amethystHideOthers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run /usr/bin/defaults write -g NSUserKeyEquivalents -dict-add "Hide Others" '@~^$h'
    '';

    home.activation.amethystSpaces = mkIf cfg.spaceHotkeys (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${concatMapStrings (hotkey: ''
          run /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
            -dict-add ${toString hotkey.id} '${hotkeyPlist hotkey}'
        '') symbolicHotkeys}
        # Applies the shortcuts without logging out.
        run /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

        # Desktop numbers must not move around for Command+N to mean anything.
        # The Dock only reads this at start, so restart it, but only on change.
        if [ "$(/usr/bin/defaults read com.apple.dock mru-spaces 2>/dev/null)" != "0" ]; then
          run /usr/bin/defaults write com.apple.dock mru-spaces -bool false
          run /usr/bin/killall Dock
        fi
      ''
    );
  };
}

# Not carried over from configs/hypr/bindings.lua, because Amethyst has no
# equivalent:
#
#   SUPER+CTRL+j / k                    no directional move
#   SUPER+SHIFT+CTRL+hjkl               swap shares swap-ccw / swap-cw with move
#   SUPER+CTRL+1..9, SUPER+CTRL+[ / ]   move silently: following is global
#   ALT+TAB / SHIFT+ALT+TAB             rollnext / rollprev: no rotate command
#   SUPER+ALT+G, SUPER+CTRL+TAB         groups
#   SUPER+P                             pseudo-tiling
#   SUPER+mouse_up / mouse_down         scroll through workspaces
