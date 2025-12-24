{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.gnome;

in
{
  options.programs.homenix.gnome = {
    enable = mkEnableOption "homenix gnome configuration";

    accentColor = mkOption {
      default = "blue";
      type = types.str;
      description = "Accent Color for Theme";
    };

    iconTheme = mkOption {
      default = "Papirus";
      type = types.str;
      description = "Icon theme";
    };

    dashApps = mkOption {
      default = [
        "firefox.desktop"
        "org.gnome.Calendar.desktop"
        "org.gnome.Nautilus.desktop"
      ];
      description = "Apps for the Dash";
    };
  };

  imports = [
    ./settings.nix
    ./extensions.nix
    ./keybindings.nix
  ];

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        desktop-file-utils
        gnome-settings-daemon
        gnome-tweaks
        pinentry-gnome3
        gnome.gvfs
        arc-icon-theme
        arc-theme
        fluent-icon-theme
        (pkgs.graphite-gtk-theme.override {
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
        numix-cursor-theme
        papirus-icon-theme
        reversal-icon-theme
      ];
    };

    services.gnome-keyring = {
      enable = true;
      components = [
        "pkcs11"
        "secrets"
        "ssh"
      ];
    };

    gtk.enable = true;
  };
}
