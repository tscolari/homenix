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
    enable = mkOption {
      type = types.bool;
      default = config.programs.homenix.enableAllByDefault;
      description = "Enable Hyprland Configuration";
    };

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

    presetMonitors = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Name identifier for this monitor preset";
              example = "home-office";
            };

            config = mkOption {
              type = types.lines;
              description = "Full monitors.lua content for this preset (Lua format: hl.monitor({...}), hl.config({...}))";
              example = ''
                monitor=DP-1,2560x1440@144,0x0,1
                monitor=HDMI-A-1,1920x1080@60,2560x0,1
              '';
            };

            workspaces = mkOption {
              type = types.lines;
              description = "Workspace configuration for this monitor preset";
              default = "";
              example = ''
                workspace=1,monitor:DP-1,default:true
                workspace=2,monitor:DP-1
                workspace=9,monitor:HDMI-A-1
              '';
            };
          };
        }
      );
      default = [ ];
      description = "List of monitor preset configurations";
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

  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";

      package = if config.programs.homenix.isNixOS then null else (nixGLWrapIfReq pkgs.hyprland);
      portalPackage = if config.programs.homenix.isNixOS then null else pkgs.xdg-desktop-portal-hyprland;

      xwayland.enable = true;
      systemd.enable = !cfg.useUWSM;

      extraConfig = ''
        require("envs")
        require("autostart")

        -- Catppuccin Mocha fallback colors, overridden by wallust when available
        background = "rgb(1e1e2e)"; foreground = "rgb(cdd6f4)"
        color0  = "rgb(1e1e2e)"; color1  = "rgb(cba6f7)"
        color2  = "rgb(a6e3a1)"; color3  = "rgb(f9e2af)"
        color4  = "rgb(89b4fa)"; color5  = "rgb(f5c2e7)"
        color6  = "rgb(94e2d5)"; color7  = "rgb(bac2de)"
        color8  = "rgb(585b70)"; color9  = "rgb(cba6f7)"
        color10 = "rgb(a6e3a1)"; color11 = "rgb(f9e2af)"
        color12 = "rgb(89b4fa)"; color13 = "rgb(f5c2e7)"
        color14 = "rgb(94e2d5)"; color15 = "rgb(cdd6f4)"
        pcall(require, "wallust.wallust-hyprland")

        require("decorations")
        require("settings")
        require("laptop")
        require("bindings")
        require("window_rules")
        pcall(require, "current_animation")
        pcall(require, "monitors")
        pcall(require, "workspaces")
      '';
    };

    xdg.configFile = builtins.listToAttrs (
      (map (preset: {
        name = "hypr/monitors/${preset.name}.lua";
        value = {
          text = ''
            -- Monitor configuration: ${preset.name}
            ${preset.config}
          '';
        };
      }) cfg.presetMonitors)
      ++ (map (preset: {
        name = "hypr/monitors/workspaces/${preset.name}.lua";
        value = {
          text = ''
            -- Workspaces: ${preset.name}
            ${preset.workspaces}
          '';
        };
      }) cfg.presetMonitors)
    );
  };
}
