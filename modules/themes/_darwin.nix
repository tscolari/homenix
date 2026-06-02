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
  config = mkIf (cfg.enable && config.programs.homenix.enable && pkgs.stdenv.isDarwin) {
    home.file.".config/homenix/bin/homenix-themes-choose" = {
      source = ../../bin/darwin-homenix-themes-choose;
      executable = true;
    };
  };
}
