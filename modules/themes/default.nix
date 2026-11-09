{
  pkgs,
  lib,
  config,
  ...
}:

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

  nvimThemes = import ./nvim-themes.nix { inherit pkgs; };

  # Each theme dir is the repo's themes/<theme> plus nvim/<plugin> links to the
  # colorscheme plugins in nvimThemes, so the theme stays self-contained at runtime.
  mkTheme =
    theme:
    pkgs.runCommandLocal "homenix-theme-${theme}" { } ''
      cp -r ${../../themes/${theme}} $out
      chmod -R u+w $out
      mkdir $out/nvim
      ${concatMapStrings (plugin: ''
        ln -s ${plugin} $out/nvim/${getName plugin}
      '') (nvimThemes.${theme} or [ ])}
    '';

  themeLinks = builtins.listToAttrs (
    map (theme: {
      name = ".config/homenix/themes/${theme}";
      value = {
        source = mkTheme theme;
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
