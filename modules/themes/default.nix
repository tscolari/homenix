{ lib, config, ... }:

with lib;

let

  cfg = config.programs.homenix.themes;

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
        source = ../../themes/${theme};
      };
    }) themes
  );

in
{
  imports = [
    ./_linux.nix
    ./_darwin.nix
  ];

  options.programs.homenix.themes = {
    enable = mkOption {
      type = types.bool;
      default = config.programs.homenix.enableAllByDefault;
      description = "Enable Themes";
    };
  };

  config = mkIf config.programs.homenix.enable {
    home = {
      file = themeLinks // {
        ".config/homenix/bin/homenix-themes".source = ../../bin/homenix-themes;
      };

      activation.setupThemes = lib.hm.dag.entryAfter [ "setupHomenixConfigFolder" ] ''
        if [ ! -e ~/.config/homenix/current/theme ]; then
          ln -sf ~/.config/homenix/themes/kanagawa ~/.config/homenix/current/theme
        fi

        if [ ! -e ~/.config/homenix/current/background ]; then
          ln -sf ~/.config/homenix/themes/kanagawa/backgrounds/1-kanagawa.jpg ~/.config/homenix/current/background
        fi
      '';
    };
  };
}
