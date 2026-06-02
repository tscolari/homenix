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
  config = mkIf (cfg.enable && config.programs.homenix.enable && pkgs.stdenv.isLinux) {
    home = {
      activation.setupThemesLinux = lib.hm.dag.entryAfter [ "setupThemes" ] ''
        if [ ! -e ~/.config/homenix/current/swaync ]; then
          ln -sf ~/.config/homenix/swaync ~/.config/homenix/current/swaync
        fi
      '';
    };
  };
}
