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
    enable = mkOption {
      type = types.bool;
      default = config.programs.homenix.enableAllByDefault;
      description = "Enable GNOME Configuration";
    };

    accentColor = mkOption {
      default = "blue";
      type = types.str;
      description = "Accent Color for Theme";
    };

    iconTheme = mkOption {
      default = "Papirus-Dark";
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

  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    home = {
      packages = with pkgs; [
        desktop-file-utils
        gnome-settings-daemon
        gnome-tweaks
        pinentry-gnome3
        gnome.gvfs
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
