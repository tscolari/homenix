{ lib, config, ... }:

let

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
        source = ../themes/${theme};
      };
    }) themes
  );

in
{
  # This contains the base homenix config folder.
  # This contains common configuration (like themes) that are shared
  # across different modules of homenix.

  home = {
    file = themeLinks // {
      ".config/homenix/bin/launch-or-focus-tui".source = ../bin/launch-or-focus-tui;
      ".config/homenix/bin/launch-floating".source = ../bin/launch-floating;
      ".config/homenix/bin/omarchy-launch-webapp".source = ../bin/omarchy-launch-webapp;
      ".config/homenix/bin/omarchy-webapp-remove".source = ../bin/omarchy-webapp-remove;
      ".config/homenix/bin/omarchy-webapp-install".source = ../bin/omarchy-webapp-install;
    };

    activation.setupHomenixConfigFolder = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
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
    '';
  };
}
