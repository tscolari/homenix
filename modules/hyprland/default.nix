{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.hyprland;

  nixGLWrapIfReq = pkg: if config.lib ? nixGL then config.lib.nixGL.wrap pkg else pkg;

in
{
  options.programs.homenix.hyprland = {
    enable = mkEnableOption "homenix hyprland configuration";

    useUWSM = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to configure Hyprland for UWSM session management";
    };

    uwsmEnvExtras = mkOption {
      type = types.lines;
      default = "";
      description = "Extra UWSM env file entries";
    };

    screenLockTimeout = mkOption {
      type = types.integer;
      default = 600;
      description = "Timeout to lock the screen (in seconds)";
    };

    wallustPalette = mkOption {
      type = types.str;
      default = "dark16";
      description = "Color palette to use: dark, dark16, harddark, harddark16, light, light16, softdark, softdark16, softlight, softlight16";
    };

  };

  imports = [
    ./hypridle.nix
    ./hyprlock.nix
    ./packages.nix
    ./rofi.nix
    ./services.nix
    ./settings
    ./swaync.nix
    ./swayosd.nix
    ./uwsm.nix
    ./wallust.nix
    ./waybar.nix
    ./wlogout.nix
  ];

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = (nixGLWrapIfReq pkgs.hyprland);

      xwayland.enable = true;
      # systemd.enable = !cfg.useUWSM;

      settings = {
        source = "hyprland_main.conf";
      };
    };
  };
}
