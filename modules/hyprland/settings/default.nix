{ lib, config, ... }:

with lib;

let

  cfg = config.programs.homenix.hyprland;

  themes = [
    "catppuccin"
    "ethereal"
    "flexoki-light"
    "hackerman"
    "matte-black"
    "osaka-jade"
    "rose-pine"
    "catppuccin-latte"
    "everforest"
    "gruvbox"
    "kanagawa"
    "nord"
    "ristretto"
    "tokyo-night"
  ];

  themeLinks = builtins.listToAttrs (
    map (theme: {
      name = ".config/homenix/themes/${theme}";
      value = {
        source = ../../../themes/${theme};
      };
    }) themes
  );

in
{
  imports = [ ];

  config = mkIf cfg.enable {
    home = {
      file = themeLinks // {
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

        ".config/homenix/bin/launch-or-focus-tui".source = ../../../bin/launch-or-focus-tui;
        ".config/homenix/bin/launch-floating".source = ../../../bin/launch-floating;
        ".config/homenix/bin/omarchy-launch-webapp".source = ../../../bin/omarchy-launch-webapp;
        ".config/homenix/bin/omarchy-webapp-remove".source = ../../../bin/omarchy-webapp-remove;
        ".config/homenix/bin/omarchy-webapp-install".source = ../../../bin/omarchy-webapp-install;
      };

      activation.createHyprlandWritableFolders = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ~/.config/hypr/monitor_profiles/workspaces
        mkdir -p ~/.config/hypr/before
        mkdir -p ~/.config/hypr/after

        mkdir -p ~/.config/homenix/current
        if [ ! -e ~/.config/homenix/current/theme ]; then
          ln -sf ~/.config/homenix/themes/kanagawa ~/.config/homenix/current/theme
        fi

        if [ ! -e ~/.config/homenix/current/swaync ]; then
          ln -sf ~/.config/homenix/swaync ~/.config/homenix/current/swaync
        fi

        if [ ! -e ~/.config/homenix/current/background ]; then
          ln -sf ~/.config/homenix/themes/kanagawa/backgrounds/1-kanagawa.jpg ~/.config/homenix/current/background
        fi

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
