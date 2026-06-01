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
      maccy  # clipboard manager — configure shortcut and history via app preferences
    ];
  };
}
