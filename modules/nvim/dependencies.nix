{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.nvim;

in
{
  config = mkIf cfg.enable {
    programs.nixvim.extraPackages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      texliveFull
      zathura
    ];
  };
}
