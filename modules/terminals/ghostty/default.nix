{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.terminals.ghostty;

  nixGLWrapIfReq = pkg: if config.lib ? nixGL then config.lib.nixGL.wrap pkg else pkg;

in

{
  options.programs.homenix.terminals.ghostty = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable ghostty terminal";
    };

    defaultTerminal = mkOption {
      type = types.bool;
      default = true;
      description = "Set ghostty as default terminal for xdg-terminal-exec";
    };
  };

  config =
    mkIf (config.programs.homenix.enable && config.programs.homenix.terminals.enable && cfg.enable)
      {
        programs.ghostty = {
          enable = true;
          package = (nixGLWrapIfReq pkgs.ghostty);

          settings = {
            # Dynamic theme colors
            config-file = "?\"~/.config/homenix/current/theme/ghostty.conf\"";

            # Font
            "font-family" = "JetBrainsMono Nerd Font";
            "font-style" = "Regular";
            "font-size" = 9;

            # Window
            "window-theme" = "ghostty";
            "window-padding-x" = 14;
            "window-padding-y" = 14;
            "confirm-close-surface" = false;
            "resize-overlay" = "never";
            "gtk-toolbar-style" = "flat";

            # Cursor styling
            "cursor-style" = "block";
            "cursor-style-blink" = false;

            # Cursor styling + SSH session terminfo
            # (all shell integration options must be passed together)
            "shell-integration-features" = "no-cursor,ssh-env";

            # Keyboard bindings
            keybind = [
              "shift+insert=paste_from_clipboard"
              "control+insert=copy_to_clipboard"
              "super+control+shift+alt+arrow_down=resize_split:down,100"
              "super+control+shift+alt+arrow_up=resize_split:up,100"
              "super+control+shift+alt+arrow_left=resize_split:left,100"
              "super+control+shift+alt+arrow_right=resize_split:right,100"
            ];

            # Slowdown mouse scrolling
            "mouse-scroll-multiplier" = 0.95;
          };
        };

        home.activation.setGhosttyDefaultTerminal = mkIf cfg.defaultTerminal (
          lib.hm.dag.entryAfter [ "setupHomenixConfigFolder" ] ''
            rm -rf ~/.config/xdg-terminals.list
            echo "com.mitchellh.ghostty.desktop" > ~/.config/xdg-terminals.list
          ''
        );
      };
}
