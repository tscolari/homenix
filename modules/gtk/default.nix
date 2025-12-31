{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.gtk;

in
{
  options.programs.homenix.gtk = {
    enable = mkOption {
      type = types.bool;
      default = config.programs.homenix.hyprland.enable || config.programs.homenix.gnome.enable;
      description = "Enable GTK Configuration";
    };
  };

  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    gtk = {
      enable = true;

      cursorTheme = {
        name = "Rose-Pine";
        package = pkgs.rose-pine-cursor;
        size = 35;
      };

      theme = {
        name = "Adwaita-dark";
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };

    home = {
      packages = with pkgs; [
        numix-cursor-theme
        arc-icon-theme
        arc-theme
        fluent-icon-theme
        bibata-cursors
        rose-pine-cursor
        (graphite-gtk-theme.override {
          colorVariants = [
            "light"
            "dark"
          ];
          themeVariants = [
            "default"
            "purple"
            "blue"
            "red"
          ];
          sizeVariants = [ "standard" ];
          tweaks = [ "rimless" ];
        })
        papirus-icon-theme
        reversal-icon-theme
      ];

      pointerCursor = {
        name = "Rose-Pine";
        size = 24;
        package = pkgs.rose-pine-cursor;
        gtk.enable = true;
        x11.enable = true;
        hyprcursor.enable = true;
      };
    };
  };
}
