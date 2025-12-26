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

in
{
  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      package = (nixGLWrapIfReq pkgs.waybar);

      # Only enable for NixOS.
      # On non-nixos it will be started in services.nix with a proper nixGL wrapper.
      # BUG: waybar systemd unit won't use the `package` set.
      systemd = {
        enable = isNixOS;
        target = "graphical-session.target";
      };

      settings = {
        mainBar = {
          "include" = [
            # "$HOME/.config/waybar/Modules"
            # "$HOME/.config/waybar/ModulesWorkspaces"
            # "$HOME/.config/waybar/ModulesCustom"
            # "$HOME/.config/waybar/ModulesGroups"
            # "$HOME/.config/waybar/UserModules"
          ];
          "reload_style_on_change" = true;
          "layer" = "top";
          "position" = "top";
          "spacing" = 0;
          "height" = 26;
          "modules-left" = [
            "hyprland/workspaces"
          ];
          "modules-center" = [
            "group/notify"
            "custom/separator#blank_2"
            "custom/calendar-clock"
            # "custom/screenrecording-indicator"
            "custom/separator#blank_2"
            "custom/weather"
          ];
          "modules-right" = [
            "group/tray-expander"
            "bluetooth"
            "network"
            "pulseaudio"
            "cpu"
            "battery"
          ];
          "hyprland/workspaces" = {
            "on-click" = "activate";
            "format" = "{icon}";
            "format-icons" = {
              "default" = "";
              "1" = "1";
              "2" = "2";
              "3" = "3";
              "4" = "4";
              "5" = "5";
              "6" = "6";
              "7" = "7";
              "8" = "8";
              "9" = "9";
              "10" = "0";
              "active" = "󱓻";
            };
            "persistent-workspaces" = {
              "1" = [ ];
              "2" = [ ];
              "3" = [ ];
              "4" = [ ];
              "5" = [ ];
            };
          };
          # "custom/update" = {
          #   "format" = "";
          #   "exec" = "omarchy-update-available";
          #   "on-click" = "omarchy-launch-floating-terminal-with-presentation omarchy-update";
          #   "tooltip-format" = "Omarchy update available";
          #   "signal" = 7;
          #   "interval" = 21600;
          # };

          "cpu" = {
            "interval" = 5;
            "format" = "󰍛";
            "on-click" = "${config.home.homeDirectory}/.config/homenix/bin/launch-or-focus-tui btop";
          };

          "group/notify" = {
            "orientation" = "inherit";
            "drawer" = {
              "transition-duration" = 500;
              "children-class" = "custom/swaync";
              "transition-left-to-right" = false;
            };
            "modules" = [
              "custom/swaync"
            ];
          };

          "custom/swaync" = {
            "tooltip" = true;
            "tooltip-format" = "Left Click= Launch Notification Center\nRight Click= Do not Disturb";
            "format" = "{} {icon} ";
            "format-icons" = {
              "notification" = "<span foreground='red'><sup></sup></span>";
              "none" = "";
              "dnd-notification" = "<span foreground='red'><sup></sup></span>";
              "dnd-none" = "";
              "inhibited-notification" = "<span foreground='red'><sup></sup></span>";
              "inhibited-none" = "";
              "dnd-inhibited-notification" = "<span foreground='red'><sup></sup></span>";
              "dnd-inhibited-none" = "";
            };
            "return-type" = "json";
            "exec-if" = "which swaync-client";
            "exec" = "swaync-client -swb";
            "on-click" = "sleep 0.1 && swaync-client -t -sw";
            "on-click-right" = "swaync-client -d -sw";
            "escape" = true;
          };

          "custom/calendar-clock" = {
            "exec" = "${config.home.homeDirectory}/.config/hypr/scripts/calendar_clock.sh";
            "return-type" = "json";
            "interval" = 3;
            "on-click" =
              "swaync-client -cp && ${config.home.homeDirectory}/.config/homenix/bin/launch-floating ${config.home.homeDirectory}/.config/homenix/bin/launch-or-focus-tui calcure";
          };

          "custom/weather" = {
            "format" = "{}";
            "format-alt" = "{alt}= {}";
            "format-alt-click" = "click";
            "interval" = 3600;
            "return-type" = "json";
            "exec" = "${config.home.homeDirectory}/.config/hypr/scripts/weather.sh";
            "tooltip" = true;
          };

          "network" = {
            "format-icons" = [
              "󰤯"
              "󰤟"
              "󰤢"
              "󰤥"
              "󰤨"
            ];
            "format" = "{icon}";
            "format-wifi" = "{icon}";
            "format-ethernet" = "󰀂";
            "format-disconnected" = "󰤮";
            "tooltip-format-wifi" = "{essid} ({frequency} GHz)\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
            "tooltip-format-ethernet" = "⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
            "tooltip-format-disconnected" = "Disconnected";
            "interval" = 3;
            "spacing" = 1;
            "on-click" = "${config.home.homeDirectory}/.config/homenix/bin/launch-or-focus-tui wifitui";
          };
          "battery" = {
            "format" = "{capacity}% {icon}";
            "format-discharging" = "{icon}";
            "format-charging" = "{icon}";
            "format-plugged" = "";
            "format-icons" = {
              "charging" = [
                "󰢜"
                "󰂆"
                "󰂇"
                "󰂈"
                "󰢝"
                "󰂉"
                "󰢞"
                "󰂊"
                "󰂋"
                "󰂅"
              ];
              "default" = [
                "󰁺"
                "󰁻"
                "󰁼"
                "󰁽"
                "󰁾"
                "󰁿"
                "󰂀"
                "󰂁"
                "󰂂"
                "󰁹"
              ];
            };
            "format-full" = "󰂅";
            # "tooltip-format-discharging" = "{power=>1.0f}W↓ {capacity}%";
            # "tooltip-format-charging" = "{power=>1.0f}W↑ {capacity}%";
            "interval" = 5;
            "on-click" = "${config.home.homeDirectory}/.config/hypr/scripts/power_menu.sh";
            "states" = {
              "warning" = 20;
              "critical" = 10;
            };
          };
          "bluetooth" = {
            "format" = "";
            "format-disabled" = "󰂲";
            "format-connected" = "󰂱";
            "format-no-controller" = "";
            "tooltip-format" = "Devices connected= {num_connections}";
            "on-click" = "${config.home.homeDirectory}/.config/homenix/bin/launch-or-focus-tui bluetui";
          };
          "pulseaudio" = {
            "format" = "{icon}";
            "on-click" =
              "${config.home.homeDirectory}/.config/homenix/bin/launch-floating /home/tiagoscolari/.config/homenix/bin/launch-or-focus-tui wiremix";
            "on-click-right" = "pamixer -t";
            "tooltip-format" = "Playing at {volume}%";
            "scroll-step" = 5;
            "format-muted" = "";
            "format-icons" = {
              "default" = [
                ""
                ""
                ""
              ];
            };
          };
          "group/tray-expander" = {
            "orientation" = "inherit";
            "drawer" = {
              "transition-duration" = 600;
              "children-class" = "tray-group-item";
            };
            "modules" = [
              "custom/expand-icon"
              "tray"
            ];
          };
          "custom/expand-icon" = {
            "format" = "";
            "tooltip" = false;
          };
          # "custom/screenrecording-indicator" = {
          #   "on-click" = "omarchy-cmd-screenrecord";
          #   "exec" = "$OMARCHY_PATH/default/waybar/indicators/screen-recording.sh";
          #   "signal" = 8;
          #   "return-type" = "json";
          # };
          "tray" = {
            "icon-size" = 12;
            "spacing" = 17;
          };

          # Separators
          "custom/separator#dot" = {
            "format" = "";
            "interval" = "once";
            "tooltip" = false;
          };
          "custom/separator#dot-line" = {
            "format" = "";
            "interval" = "once";
            "tooltip" = false;
          };
          "custom/separator#line" = {
            "format" = "|";
            "interval" = "once";
            "tooltip" = false;
          };
          "custom/separator#blank" = {
            "format" = "";
            "interval" = "once";
            "tooltip" = false;
          };
          "custom/separator#blank_2" = {
            "format" = "  ";
            "interval" = "once";
            "tooltip" = false;
          };
          "custom/separator#blank_3" = {
            "format" = "   ";
            "interval" = "once";
            "tooltip" = false;
          };
        };
      };

      style = ''
        @import "${config.home.homeDirectory}/.config/homenix/current/theme/waybar.css";

        * {
          background-color: @background;
          color: @foreground;

          border: none;
          border-radius: 0;
          min-height: 0;
          font-family: 'JetBrainsMono Nerd Font';
          font-size: 12px;
        }

        .modules-left {
          margin-left: 8px;
        }

        .modules-right {
          margin-right: 8px;
        }

        #workspaces button {
          all: initial;
          padding: 0 6px;
          margin: 0 1.5px;
          min-width: 9px;
        }

        #workspaces button.empty {
          opacity: 0.5;
        }

        #cpu,
        #battery,
        #pulseaudio,
        #custom-omarchy,
        #custom-screenrecording-indicator,
        #custom-update {
          min-width: 12px;
          margin: 0 7.5px;
        }

        #tray {
          margin-right: 16px;
        }

        #bluetooth {
          margin-right: 17px;
        }

        #network {
          margin-right: 13px;
        }

        #custom-expand-icon {
          margin-right: 18px;
        }

        tooltip {
          padding: 2px;
        }

        #custom-update {
          font-size: 10px;
        }

        #clock {
          margin-left: 8.75px;
        }

        .hidden {
          opacity: 0;
        }

        #custom-screenrecording-indicator {
          min-width: 12px;
          margin-left: 8.75px;
          font-size: 10px;
        }

        #custom-screenrecording-indicator.active {
          color: #a55555;
        }
      '';
    };
  };
}
