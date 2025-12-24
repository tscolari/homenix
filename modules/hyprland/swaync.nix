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
  config = mkIf cfg.enable {
    home.file = {
      ".config/homenix/swaync".source = ../../configs/swaync;
    };

    services.swaync = {
      enable = true;
      package = (nixGLWrapIfReq pkgs.swaynotificationcenter);

      settings = {
        "$schema" = "/etc/xdg/swaync/configSchema.json";
        "positionX" = "center";
        "positionY" = "top";
        "layer" = "overlay";
        "control-center-layer" = "top";
        "layer-shell" = true;
        "cssPriority" = "user";
        "control-center-margin-top" = 5;
        "control-center-margin-bottom" = 0;
        "control-center-margin-right" = 0;
        "control-center-margin-left" = 0;
        "notification-2fa-action" = true;
        "notification-inline-replies" = false;
        "notification-icon-size" = 24;
        "notification-body-image-height" = 100;
        "notification-body-image-width" = 100;
        "notification-window-width" = 300;
        "timeout" = 6;
        "timeout-low" = 3;
        "timeout-critical" = 0;
        "fit-to-screen" = false;
        "control-center-width" = 450;
        "control-center-height" = 720;
        "keyboard-shortcuts" = true;
        "image-visibility" = "when-available";
        "transition-time" = 200;
        "hide-on-clear" = false;
        "hide-on-action" = true;
        "script-fail-notify" = true;
        "widgets" = [
          "dnd"
          "buttons-grid"
          "mpris"
          "volume"
          "backlight"
          "title"
          "notifications"
        ];
        "widget-config" = {
          "title" = {
            "text" = "Notifications";
            "clear-all-button" = true;
            "button-text" = "Clear";
          };
          "dnd" = {
            "text" = "Do Not Disturb";
          };
          "label" = {
            "max-lines" = 1;
            "text" = "Notification";
          };
          "mpris" = {
            "image-size" = 12;
            "image-radius" = 0;
          };
          "volume" = {
            "label" = "󰕾";
          };
          "backlight" = {
            "label" = "󰃟";
          };
          "buttons-grid" = {
            "actions" = [
              {
                "label" = "󰐥";
                "command" = "bash -c ${config.home.homeDirectory}/.config/hypr/scripts/power_menu.sh";
              }
              {
                "label" = "󰌾";
                "command" = "loginctl lock-session";
              }
              {
                "label" = "󰍃";
                "command" = "uwsm stop";
              }
              {
                "label" = "󰀝";
                "command" = "bash -c ${config.home.homeDirectory}/.config/hypr/scripts/airplane_mode.sh";
              }
              {
                "label" = "󰝟";
                "command" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
              }
              {
                "label" = "󰂯";
                "command" = "blueman-manager";
              }
              {
                "label" = "󰃭";
                "command" =
                  "swaync-client -cp && ${config.home.homeDirectory}/.config/homenix/bin/launch-floating ${config.home.homeDirectory}/.config/homenix/bin/launch-or-focus-tui calcure";
              }
            ];
          };
        };
      };

      style = mkForce ''
        @import '${config.home.homeDirectory}/.config/waybar/wallust/colors-waybar.css';

        @define-color noti-border-color @color12;
        @define-color noti-bg rgba(0, 0, 0, 0.8);
        @define-color noti-bg-alt @background-alt;
        @define-color noti-bg-hover @background;
        @define-color text-color @foreground;

        * {
            font-family: "JetBrains Mono Nerd Font";
            font-weight: bold;
            font-size: 1rem;
        }

        .control-center .notification-row:focus,
        .control-center .notification-row:hover {
            opacity: 1;
            background: @noti-bg;
            border-radius: 0px;
        }

        .notification-row {
            outline: none;
        }

        .notification {
            /*color: @text-color;*/
            background: @noti-bg;
            padding: 3px 10px 3px 6px;
            border-radius: 0px;
            border: 4px solid @noti-border-color;
        }

        .notification-default-action {
            margin: 0;
            padding: 0;
            border-radius: 0px;
        }

        .close-button {
            background: #f7768e;
            color: @noti-bg;
            text-shadow: none;
            padding: 0;
            border-radius: 0px;
            margin-top: 4px;
            margin-right: 4px;
        }

        .close-button:hover {
            box-shadow: none;
            background: #f7768e;
            transition: all .15s ease-in-out;
            border: none
        }


        .notification-action {
            border: 1px solid @noti-border-color;
            border-top: none;
            border-radius: 0;
        }


        .notification-default-action:hover,
        .notification-action:hover {
            color: @text-color;
            background: @noti-bg
        }


        .notification-default-action {
            border-radius: 0px;
            margin: 5px;
        }

        .notification-default-action:not(:only-child) {
            border-bottom-left-radius: 7px;
            border-bottom-right-radius: 7px
        }

        .notification-action:first-child {
            border-bottom-left-radius: 10px;
            background: @noti-bg;
        }

        .notification-action:last-child {
            border-radius: 0px;
            background: @noti-bg-alt;
        }

        .inline-reply {
            margin-top: 8px;
        }

        .inline-reply-entry {
            background: @noti-bg;
            color: @text-color;
            caret-color: @text-color;
            border: 1px solid @noti-border-color;
            border-radius: 0px
        }

        .inline-reply-button {
        	font-size: 0.5rem;
            margin-left: 4px;
            background: @noti-bg;
            border: 1px solid @noti-border-color;
            border-radius: 0px;
            color: @text-color
        }

        .inline-reply-button:disabled {
            background: initial;
            color: @text-color;
            border: 1px solid transparent
        }

        .inline-reply-button:hover {
            background: @noti-bg-hover
        }

        .body-image {
            margin-top: 6px;
            color: @text-color;
            border-radius: 0px;
        }

        .summary {
            font-size: 1rem;
            font-weight: bold;
            background: transparent;
            color: @text-color;
            text-shadow: none
        }

        .time {
            font-size: 1rem;
            font-weight: bold;
            background: transparent;
            color: @text-color;
            text-shadow: none;
            margin-right: 18px
        }

        .body {
            font-size: 0.75rem;
            font-weight: normal;
            background: transparent;
            color: @text-color;
            text-shadow: none
        }

        .control-center {
            background: @noti-bg;
            border: 1px solid @noti-border-color;
        	color: @text-color;
            border-radius: 0px;
        }

        .control-center-list {
            background: transparent
        }

        .control-center-list-placeholder {
            opacity: 0.5
        }

        .floating-notifications {
            background: transparent;
        }

        .blank-window {
            background: alpha(black, 0.1)
        }

        .widget-title {
            color: @text-color;
            background: @noti-bg-alt;
            padding: 3px 6px;
            margin: 5px;
            font-size: 1rem;
            border-radius: 0px;
        }

        .widget-title>button {
            font-size: 0.75rem;
            color: @text-color;
            border-radius: 0px;
        	background: transparent;
        	border: 0.5px solid @noti-border-color;
        }

        /* clear button */
        .widget-title>button:hover {
            background: @text-color;
            color: red;
        }

        .widget-dnd {
            background: @noti-bg-alt;
            padding: 3px 6px;
            margin: 5px;
            border-radius: 10px;
            font-size: 0.5rem;
            color: @noti-border-color;
        }

        .widget-dnd>switch {
            border-radius: 10px;
            border: 1px solid @noti-border-color;
            background: @noti-border-color;
        }

        .widget-dnd>switch:checked {
            background: #f7768e;
            border: 1px solid #f7768e;
        }

        .widget-dnd>switch slider {
            background: @noti-bg;
            border-radius: 10px
        }

        .widget-dnd>switch:checked slider {
            background: @noti-bg;
            border-radius: 10px
        }

        .widget-label {
            margin: 5px;
        }

        .widget-label>label {
            font-size: 1rem;
            color: @text-color;
        }

        .widget-mpris {
            color: @text-color;
            background: @noti-bg;
            padding: 3px 6px;
            margin: 5px;
            border-radius: 0px;
        }

        .widget-mpris > box > button {
            border-radius: 0px;
        }

        .widget-mpris-player {
            padding: 3px 6px;
            margin: 5px;
        }

        .widget-mpris-title {
            font-weight: 100;
            font-size: 1rem
        }

        .widget-mpris-subtitle {
            font-size: 0.75rem
        }

        .widget-buttons-grid {
            font-size: large;
        	color: @noti-border-color;
            padding: 2px;
            margin: 5px;
            border-radius: 0px;
            background: @noti-bg-alt;
        }

        .widget-buttons-grid>flowbox>flowboxchild>button {
            margin: 1px;
            background: @noti-bg;
            border-radius: 0px;
            color: @text-color
        }

        /* individual buttons */
        .widget-buttons-grid>flowbox>flowboxchild>button:hover {
            background: @text-color;
            color: @noti-bg-hover
        }

        .widget-menubar>box>.menu-button-bar>button {
            border: none;
            background: transparent
        }

        .topbar-buttons>button {
            border: none;
            background: transparent
        }

        .widget-volume {
            background: @noti-bg-alt;
            padding: 2px;
            margin: 10px 10px 5px 10px;
            border-radius: 0px;
            font-size: x-large;
            color: @text-color
        }

        .widget-volume>box>button {
            background: @noti-border-color;
            border: none
        }

        .per-app-volume {
            background-color: @noti-bg;
            padding: 4px 8px 8px;
            margin: 0 8px 8px;
            border-radius: 0px;
        	color: @text-color
        }

        .widget-backlight {
            background: @noti-bg-alt;
            padding: 5px;
            margin: 10px 10px 5px 10px;
            border-radius: 0px;
            font-size: x-large;
            color: @text-color
        }
      '';
    };
  };
}
