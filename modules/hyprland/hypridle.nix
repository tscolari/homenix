{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.hyprland;

in
{
  options.programs.homenix.hyprland.screenlock = {
    lockTimeout = mkOption {
      type = types.int;
      default = 360;
      description = "Timeout to lock the screen (in seconds)";
    };

    screenTimeout = mkOption {
      type = types.int;
      default = 660;
      description = "Timeout to lock the screen (in seconds)";
    };

    ignoreInhibits = mkOption {
      type = types.bool;
      default = false;
      description = "whether to ignore dbus-sent idle-inhibit requests (used by e.g. firefox or steam)";
    };
  };

  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          # runs hyprlock if it is not already running (this is always run when "loginctl lock-session" is called)
          lock_cmd = "pidof hyprlock || hyprlock";

          # kill hyprlock before suspend to avoid stale Wayland handles
          before_sleep_cmd = "pkill -x hyprlock";

          # after resume: wait for compositor to stabilize, turn on display, and lock the session
          after_sleep_cmd = "sleep 2 && hyprctl dispatch dpms on && loginctl lock-session";

          # whether to ignore dbus-sent idle-inhibit requests (used by e.g. firefox or steam)
          ignore_dbus_inhibit = cfg.screenlock.ignoreInhibits;

          inhibit_sleep = 3;
        };

        listener = [
          {
            # Lock Screen
            timeout = cfg.screenlock.lockTimeout;
            # command to run when timeout has passed
            on-timeout = "loginctl lock-session";
          }
          {
            # Screen off
            timeout = cfg.screenlock.screenTimeout;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on && brightnessctl - r";
          }
        ];
      };
    };
  };
}
