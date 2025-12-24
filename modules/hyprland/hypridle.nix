{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.hyprland;

  nixGLWrapIfReq = pkg: if config.lib ? nixGL then config.lib.nixGL.wrap pkg else pkg;

in
{
  options.programs.homenix.hyprland.screenlock = {
    timeout = mkOption {
      type = types.int;
      default = 600;
      description = "Timeout to lock the screen (in seconds)";
    };

    ignoreInhibits = mkOption {
      type = types.bool;
      default = false;
      description = "whether to ignore dbus-sent idle-inhibit requests (used by e.g. firefox or steam)";
    };
  };

  config = mkIf cfg.enable {
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          # runs hyprlock if it is not already running (this is always run when "loginctl lock-session" is called)
          lock_cmd = "pidof hyprlock || hyprlock";

          # kill hyprlock before suspend to avoid stale Wayland handles
          before_sleep_cmd = "loginctl lock-session";

          # after resume: wait for compositor to stabilize, turn on display, and lock the session
          after_sleep_cmd = "sleep 2 && hyprctl dispatch dpms on && loginctl lock-session";

          # whether to ignore dbus-sent idle-inhibit requests (used by e.g. firefox or steam)
          ignore_dbus_inhibit = cfg.screenlock.ignoreInhibits;
        };

        listener = {
          timeout = cfg.screenlock.timeout;
          # command to run when timeout has passed
          on-timeout = "loginctl lock-session";
        };
      };
    };
  };
}
