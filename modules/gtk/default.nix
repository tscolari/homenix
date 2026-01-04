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

      gtk3.enable = true;
      gtk4.enable = true;

      cursorTheme = {
        name = mkForce "rose-pine";
        package = mkForce pkgs.rose-pine-cursor;
        size = 64;
      };

      theme = {
        name = "Adwaita-dark";
      };

      iconTheme = {
        name = mkForce "Papirus-Dark";
        package = mkForce pkgs.papirus-icon-theme;
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
        gtk3
        gtk4

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
        name = "rose-pine";
        size = 64;
        package = pkgs.rose-pine-hyprcursor;
        gtk.enable = true;
        x11.enable = true;
        hyprcursor.enable = true;
      };
    };
  };
}
