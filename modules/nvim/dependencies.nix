{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

let

  enabled = (config.programs.homenix.enable && config.programs.homenix.nvim.enable);

in
{
  config = mkIf enabled {
    programs.nixvim.extraPackages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      texliveFull
      zathura
    ];
  };
}
