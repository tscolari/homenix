{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.fonts;

in

{
  imports = [ ./_darwin.nix ];

  options.programs.homenix.fonts = {
    enable = mkOption {
      type = types.bool;
      default = config.programs.homenix.enableAllByDefault;
      description = "Enable font packages and platform-specific font discovery";
    };
  };

  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    home.packages = with pkgs; [
      # Noto families
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      # Prose / UI
      ia-writer-duospace
      lexend # used by waybar as primary font

      # Nerd Fonts
      nerd-fonts.jetbrains-mono # primary font across terminals, bars, lock screen
      nerd-fonts.caskaydia-mono
      nerd-fonts.fira-code # nvim icon rendering
      nerd-fonts.fira-mono # nvim icon rendering
    ];
  };
}
