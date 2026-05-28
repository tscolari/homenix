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

          # After resume: give the compositor and i915 DRM a moment to stabilize,
          # then toggle dpms off→on to force a real state transition — dpms on alone
          # is a no-op when Hyprland's internal state is already "on" but the display
          # pipe is actually dark (0.55 state-sync regression).
          after_sleep_cmd = "sleep 1 && hyprctl dispatch dpms off && sleep 0.5 && hyprctl dispatch dpms on";

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
          }
          {
            # Suspend
            timeout = cfg.screenlock.suspendTimeout;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
