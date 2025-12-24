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
  };

  imports = [
    ./hypridle.nix
    ./hyprlock.nix
    ./packages.nix
    ./rofi.nix
    ./services.nix
    ./settings
    ./swaync.nix
    ./uwsm.nix
    ./waybar.nix
    ./wlogout.nix
  ];

  config = mkIf cfg.enable {
    # wayland.windowManager.hyprland = {
    #   enable = true;
    #   package = (nixGLWrapIfReq pkgs.hyprland);
    #
    #   xwayland.enable = true;
    #   systemd.enable = !cfg.useUWSM;
    # };
  };
}
