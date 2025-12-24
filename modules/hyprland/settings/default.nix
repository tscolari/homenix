{ lib, config, ... }:

with lib;

let

  cfg = config.programs.homenix.hyprland;

in
{
  imports = [ ];

  config = mkIf cfg.enable {
    home = {
      file = {
        ".config/hypr/animations".source = ../../../configs/hypr/animations;
        ".config/hypr/autostart.conf".source = ../../../configs/hypr/autostart.conf;
        ".config/hypr/bindings.conf".source = ../../../configs/hypr/bindings.conf;
        ".config/hypr/decorations.conf".source = ../../../configs/hypr/decorations.conf;
        ".config/hypr/envs.conf".source = ../../../configs/hypr/envs.conf;
        ".config/hypr/hyprland.conf".source = ../../../configs/hypr/hyprland.conf;
        ".config/hypr/laptop.conf".source = ../../../configs/hypr/laptop.conf;
        ".config/hypr/scripts".source = ../../../configs/hypr/scripts;
        ".config/hypr/settings.conf".source = ../../../configs/hypr/settings.conf;
        ".config/hypr/window_rules.conf".source = ../../../configs/hypr/window_rules.conf;
      };

      activation.createHyprlandWritableFolders = lib.hm.dag.entryAfter [ "setupHomenixConfigFolder" ] ''
        mkdir -p ~/.config/hypr/monitor_profiles/workspaces
        mkdir -p ~/.config/hypr/before
        mkdir -p ~/.config/hypr/after

        if [ ! -e ~/.config/hypr/wallust/wallust-hyprland.conf ]; then
          ~/.config/hypr/scripts/wallust.sh ~/.config/homenix/current/background
        fi

        if [ ! -e ~/.config/hypr/current_animation.conf ]; then
          ln -sf ~/.config/hypr/animations/00-default.conf ~/.config/hypr/current_animation.conf
        fi
      '';
    };
  };
}
