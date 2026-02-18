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
  config = mkIf (config.programs.homenix.enable && cfg.enable) {
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
            "group/notify"
            "hyprland/workspaces"
          ];
          "modules-center" = [
            "hyprland/window"
          ];
          "modules-right" = [
            "tray"
            "bluetooth"
            "network"
            "pulseaudio"
            "cpu"
            "battery"
            "custom/separator#blank_2"
            "custom/weather"
            "clock"
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

          "hyprland/window" = {
            "format" = "{}";
            "rewrite" = {
              "(.*) — Mozilla Firefox" = "$1";
            };
            "max-length" = 120;
            "separate-outputs" = true;
          };

          "clock" = {
            "format" = "  {:%H:%M:%S (%Z)    %d, %A}";
            "on-click" =
              "swaync-client -cp && /nix/store/k9ja157afyxx0y8q4ijzs2zr0r1a3f51-gnome-calendar-49.0.1/bin/gnome-calendar";
            "tooltip-format" = "<span>{tz_list}</span><span>{calendar}</span>";
            "timezones" = [
              "Etc/UTC"
              "America/New_York"
              "America/Sao_Paulo"
              "America/Los_Angeles"
            ];
            "calendar" = {
              "mode" = "month";
              "format" = {
                "months" = "<span color='#ff6699'><b>{}</b></span>";
                "days" = "<span color='#cdd6f4'><b>{}</b></span>";
                "weekdays" = "<span color='#7CD37C'><b>{}</b></span>";
                "today" = "<span color='#ffcc66'><b>{}</b></span>";
              };
            };
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
          min-height: 0;
          min-width: 0;
          font-family: Lexend, "JetBrainsMono NFP";
          font-size: 12px;
          font-weight: 600;
        }

        window#waybar {
          transition-property: background-color;
          transition-duration: 0.5s;
          /* background-color: #1e1e2e; */
          /* background-color: #181825; */
          /* background-color: @background; */
          /* background-color: rgba(24, 24, 37, 0.6); */
          background-color: rgba(24, 24, 37, 0);
        }

        #workspaces button {
          padding: 0.3rem 0.6rem;
          margin: 0.2rem 0.25rem;
          border-radius: 6px;
          /* background-color: @foreground; */
          background-color: @background;
          color: @foreground;
        }

        #workspaces button:hover {
          color: #1e1e2e;
          background-color: #cdd6f4;
        }

        #workspaces button.active {
          background-color: #1e1e2e;
          color: #89b4fa;
        }

        #workspaces button.urgent {
          background-color: #1e1e2e;
          color: #f38ba8;
        }

        #clock,
        #battery,
        #custom-weather,
        #bluetooth,
        #pulseaudio,
        #custom-logo,
        #custom-power,
        #notify,
        #network,
        #custom-spotify,
        #custom-notification,
        #cpu,
        #tray,
        #memory,
        #window,
        #mpris {
          padding: 0.3rem 0.6rem;
          margin: 0.2rem 0.25rem;
          border-radius: 6px;
          /* background-color: #181825; */
          background-color: @background;
        }

        #mpris.playing {
          color: #a6e3a1;
        }

        #mpris.paused {
          color: #9399b2;
        }

        #custom-sep {
          padding: 0px;
          color: #585b70;
        }

        window#waybar.empty #window {
          background-color: transparent;
        }

        #cpu {
          color: #94e2d5;
        }

        #memory {
          color: #cba6f7;
        }

        #clock {
          color: #74c7ec;
        }

        #window {
          color: #cba6f7;
        }

        #custom-weather {
          color: #f38ba8;
        }

        #pulseaudio {
          color: #b4befe;
        }

        #pulseaudio.muted {
          color: #a6adc8;
        }

        #custom-logo {
          color: #89b4fa;
        }

        #custom-power {
          color: #f38ba8;
        }

        tooltip {
          background-color: #181825;
          border: 2px solid #89b4fa;
        }
      '';
    };
  };
}
