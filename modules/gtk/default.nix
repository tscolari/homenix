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
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
        hyprcursor.enable = true;
      };
    };
  };
}
