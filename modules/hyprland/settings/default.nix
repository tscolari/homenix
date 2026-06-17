{ lib, config, ... }:

with lib;

let

  cfg = config.programs.homenix.hyprland;

in
{
  imports = [ ];

  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    home = {
      file = {
        ".config/hypr/animations".source = ../../../configs/hypr/animations;
        ".config/hypr/autostart.lua".source = ../../../configs/hypr/autostart.lua;
        ".config/hypr/bindings.lua".source = ../../../configs/hypr/bindings.lua;
        ".config/hypr/decorations.lua".source = ../../../configs/hypr/decorations.lua;
        ".config/hypr/envs.lua".source = ../../../configs/hypr/envs.lua;
        ".config/hypr/laptop.lua".source = ../../../configs/hypr/laptop.lua;
        ".config/hypr/scripts".source = ../../../configs/hypr/scripts;
        ".config/hypr/settings.lua".source = ../../../configs/hypr/settings.lua;
        ".config/hypr/window_rules.lua".source = ../../../configs/hypr/window_rules.lua;
      };

      activation.createHyprlandWritableFolders = lib.hm.dag.entryAfter [ "setupHomenixConfigFolder" ] ''
        mkdir -p ~/.config/hypr/monitor_profiles/workspaces
        mkdir -p ~/.config/hypr/before
        mkdir -p ~/.config/hypr/after

        if [ ! -e ~/.config/hypr/wallust/wallust-hyprland.lua ]; then
          ~/.config/hypr/scripts/wallust.sh ~/.config/homenix/current/background
        fi

        if [ ! -e ~/.config/hypr/current_animation.lua ]; then
          ln -sf ~/.config/hypr/animations/00-default.lua ~/.config/hypr/current_animation.lua
        fi
      '';
    };
  };
}
