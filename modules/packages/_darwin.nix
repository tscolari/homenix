{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.packages;

in

{
  config = mkIf (cfg.enable && config.programs.homenix.enable && !pkgs.stdenv.isLinux) {
    home.packages = with pkgs; [
      # Add macOS-only packages here
    ];
  };
}
