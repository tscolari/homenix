{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.themes;

in

{
  config = mkIf (cfg.enable && config.programs.homenix.enable && !pkgs.stdenv.isLinux) {
    home.packages = with pkgs; [
    ];
  };
}
