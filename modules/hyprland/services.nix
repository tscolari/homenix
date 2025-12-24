{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.hyprland;

  isNixOS = config.programs.homenix.isNixOS;

  nixGLWrapIfReq = pkg: if config.lib ? nixGL then config.lib.nixGL.wrap pkg else pkg;

  # Helper to create a graphical session service
  mkGraphicalService =
    {
      description,
      execStart,
      restartPolicy ? "on-failure",
      extraConfig ? { },
    }:
    {
      Unit = {
        Description = description;
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = execStart;
        Restart = restartPolicy;
        PassEnvironment = [
          "PATH"
          "LD_LIBRARY_PATH"
          "LIBGL_DRIVERS_PATH"
          "GBM_BACKENDS_PATH"
          "LIBVA_DRIVERS_PATH"
          "__EGL_VENDOR_LIBRARY_FILENAMES"
        ];
      }
      // extraConfig;
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

in
{

  config = mkIf cfg.enable {

    programs.ags.enable = true;

    # =========================================================================
    # Home-manager managed services (use built-in modules where available)
    # =========================================================================
    services = {
      network-manager-applet.enable = true;

      # Clipboard manager - home-manager has built-in support
      cliphist = {
        enable = true;
        allowImages = true;
        # extraOptions = [ "-max-items" "25" ]; # Add if supported in your HM version
      };
    };

    # =========================================================================
    # Custom systemd user services for apps that don't have HM modules
    # =========================================================================
    systemd.user.services = {

      # Waybar - Status bar.
      # This is only necessary for non-nixos systems.
      waybar = mkIf (!isNixOS) (mkGraphicalService {
        description = "Highly customizable Wayland bar";
        execStart = "${nixGLWrapIfReq pkgs.waybar}/bin/waybar";
      });

      # fcitx5 - Input method framework
      fcitx5 = mkGraphicalService {
        description = "Fcitx5 Input Method";
        execStart = "${pkgs.fcitx5}/bin/fcitx5";
        extraConfig = {
          Type = "dbus";
          BusName = "org.fcitx.Fcitx5";
        };
      };

      # Swaybg - Wallpaper
      swaybg = {
        Unit = {
          Description = "Wayland wallpaper daemon";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${nixGLWrapIfReq pkgs.swaybg}/bin/swaybg -i %h/.config/homenix/current/background -m fill";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      # Evolution alarm notifications (GNOME Calendar)
      # Note: This uses system path since it's likely from Ubuntu packages
      evolution-alarm-notify = {
        Unit = {
          Description = "Evolution Calendar Alarm Notifications";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart =
            if isNixOS then
              "${pkgs.evolution-data-server}/libexec/evolution-alarm-notify"
            else
              "/usr/libexec/evolution-data-server/evolution-alarm-notify";

          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };

    # =========================================================================
    # Custom target for grouping all Hyprland session apps (optional)
    # This allows you to start/stop all apps with one command:
    #   systemctl --user start hyprland-apps.target
    #   systemctl --user stop hyprland-apps.target
    # =========================================================================
    systemd.user.targets.hyprland-apps = {
      Unit = {
        Description = "Hyprland Desktop Applications";
        After = [ "graphical-session.target" ];
        BindsTo = [ "graphical-session.target" ];
      };
    };

    xdg.portal = mkIf isNixOS {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
      config.common.default = "*";
    };

    home.activation.xdgDesktopWarning = mkIf (!isNixOS) (
      lib.hm.dag.entryAfter
        [
          "setupHomenixConfigFolder"
        ]
        ''
          echo "=========================="
          echo "You might want to manually install xdg-desktop-portal-*:"
          echo "sudo apt install xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-hyprland"
          echo "=========================="
        ''
    );
  };
}
