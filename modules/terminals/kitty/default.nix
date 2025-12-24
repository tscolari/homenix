{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.terminals.kitty;

  nixGLWrapIfReq = pkg: if config.lib ? nixGL then config.lib.nixGL.wrap pkg else pkg;

in

{
  options.programs.homenix.terminals.kitty = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable kitty terminal";
    };

    defaultTerminal = mkOption {
      type = types.bool;
      default = false;
      description = "Set kitty as default terminal for xdg-terminal-exec";
    };
  };

  config = mkIf (config.programs.homenix.terminals.enable && cfg.enable) {
    programs.kitty = {
      enable = true;
      package = (nixGLWrapIfReq pkgs.kitty);

      settings = {
        "include" = "~/.config/homenix/current/theme/kitty.conf";

        # Font
        "font_family" = "JetBrainsMono Nerd Font";
        "bold_italic_font" = "auto";
        "font_size" = 9.0;

        # Window
        "window_padding_width" = 14;
        "hide_window_decorations" = "yes";
        "confirm_os_window_close" = 0;

        # Allow remote access
        "allow_remote_control" = "yes";

        # Aesthetics
        "cursor_shape" = "block";
        "enable_audio_bell" = "no";

        # Minimal Tab bar styling
        "tab_bar_edge" = "bottom";
        "tab_bar_style" = "powerline";
        "tab_powerline_style" = "slanted";
        "tab_title_template" = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
      };

      keybindings = {
        "ctrl+insert" = "copy_to_clipboard";
        "shift+insert" = "paste_from_clipboard";
      };
    };

    home.activation.setKittyDefaultTerminal = mkIf cfg.defaultTerminal (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        rm -rf ~/.config/xdg-terminals.list
        echo "kitty.desktop" > ~/.config/xdg-terminals.list
      ''
    );
  };
}
