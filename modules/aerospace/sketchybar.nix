{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.aerospace;

in
{

  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    programs.sketchybar = {
      enable = false;
    };

    home.packages = with pkgs; [
      sketchybar-app-font
      sbarlua
    ];
  };
}
