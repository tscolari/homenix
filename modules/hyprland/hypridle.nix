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

    screensaverTimeout = mkOption {
      type = types.int;
      default = 120;
      description = "Timeout to start screensaver";
    };

    suspendTimeout = mkOption {
      type = types.int;
      default = 1800;
      description = "Timeout to suspend the system (in seconds)";
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

          # Run hyprlock directly rather than going through loginctl lock-session,
          # which hands output management to the session-lock protocol and can
          # confuse Hyprland's DPMS state on resume (Hyprland 0.54/0.55 regression).
          before_sleep_cmd = "pidof hyprlock || hyprlock";

          # After resume: ensure the display is powered on. Plain, idempotent
          # dpms on — a real suspend/resume already restores the panel, this is
          # just insurance. (Avoid output-reconfiguring tricks here: touching the
          # monitor layout while session-locked crashes Hyprland/hyprlock.)
          after_sleep_cmd = "sleep 1 && hyprctl dispatch dpms on >/dev/null 2>&1";

          # whether to ignore dbus-sent idle-inhibit requests (used by e.g. firefox or steam)
          ignore_dbus_inhibit = cfg.screenlock.ignoreInhibits;

        };

        listener = [
          # {
          #   # Screensaver
          #   timeout = cfg.screenlock.screensaverTimeout;
          #   # command to run when timeout has passed
          #   on-timeout = "jc_reborn";
          # }
          {
            # Lock Screen
            timeout = cfg.screenlock.lockTimeout;
            # command to run when timeout has passed
            on-timeout = "loginctl lock-session";
            on-resume = "hyprctl dispatch dpms on >/dev/null 2>&1";
          }
          {
            # Suspend
            timeout = cfg.screenlock.suspendTimeout;
            on-timeout = "systemctl suspend";
            on-resume = "hyprctl dispatch dpms on >/dev/null 2>&1";
          }
        ];
      };
    };
  };
}
