{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.aerospace;

in
{
  options.programs.homenix.aerospace = {
    enable = mkOption {
      type = types.bool;
      default = config.programs.homenix.enableAllByDefault;
      description = "Enable Aerospace configuration (macOS)";
    };
  };

  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    home.file.".config/homenix/bin/settings" = {
      source = ../../bin/darwin-settings;
      executable = true;
    };

    programs.aerospace = {
      enable = true;
      launchd.enable = true;
      userSettings = {
        start-at-login = true;
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;

        gaps = {
          inner.horizontal = 8;
          inner.vertical   = 8;
          outer.left       = 8;
          outer.right      = 8;
          outer.top        = 8;
          outer.bottom     = 8;
        };

        default-root-container-layout      = "tiles";
        default-root-container-orientation = "auto";
        accordion-padding                  = 30;

        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];

        mode.main.binding = {
          # Focus (cmd-h conflicts with macOS Hide; cmd-l conflicts with browser address bar)
          cmd-alt-h = "focus left";
          cmd-alt-j = "focus down";
          cmd-alt-k = "focus up";
          cmd-alt-l = "focus right";

          # Move window
          cmd-ctrl-h = "move left";
          cmd-ctrl-j = "move down";
          cmd-ctrl-k = "move up";
          cmd-ctrl-l = "move right";

          # Swap
          cmd-shift-ctrl-h = "move left";
          cmd-shift-ctrl-j = "move down";
          cmd-shift-ctrl-k = "move up";
          cmd-shift-ctrl-l = "move right";

          # Fullscreen / float toggle
          cmd-alt-f           = "fullscreen";
          cmd-alt-shift-space = "layout floating tiling";

          # Layout: accordion (group equivalent) and back to tiles
          cmd-alt-g = "layout accordion horizontal vertical";
          cmd-alt-t = "layout tiles horizontal vertical";

          # Workspace switch
          cmd-1 = "workspace 1";
          cmd-2 = "workspace 2";
          cmd-3 = "workspace 3";
          cmd-4 = "workspace 4";
          cmd-5 = "workspace 5";
          cmd-6 = "workspace 6";
          cmd-7 = "workspace 7";
          cmd-8 = "workspace 8";
          cmd-9 = "workspace 9";

          # Move to workspace
          cmd-shift-1 = "move-node-to-workspace 1";
          cmd-shift-2 = "move-node-to-workspace 2";
          cmd-shift-3 = "move-node-to-workspace 3";
          cmd-shift-4 = "move-node-to-workspace 4";
          cmd-shift-5 = "move-node-to-workspace 5";
          cmd-shift-6 = "move-node-to-workspace 6";
          cmd-shift-7 = "move-node-to-workspace 7";
          cmd-shift-8 = "move-node-to-workspace 8";
          cmd-shift-9 = "move-node-to-workspace 9";

          # Next / prev workspace (mirrors Hyprland Super+Shift+[/])
          "cmd-shift-]" = "workspace next";
          "cmd-shift-[" = "workspace prev";

          # Resize (mirrors Hyprland Super+Shift+arrows)
          cmd-shift-left  = "resize width -50";
          cmd-shift-right = "resize width +50";
          cmd-shift-up    = "resize height -50";
          cmd-shift-down  = "resize height +50";

          # App launches
          cmd-enter   = "exec-and-forget ghostty";
          cmd-shift-b = "exec-and-forget open -na 'Google Chrome'";
          cmd-shift-s = "exec-and-forget screencapture -i ~/Desktop/screenshot-$(date +%Y%m%d-%H%M%S).png";
          cmd-shift-f = "exec-and-forget open ~";
          cmd-shift-t = "exec-and-forget ~/.config/homenix/bin/homenix-themes-choose";
          cmd-ctrl-e  = "exec-and-forget ~/.config/homenix/bin/settings";
        };
      };
    };
  };
}
