{ lib, config, ... }:

with lib;

{
  # This contains the base homenix config folder.
  # This contains common configuration (like themes) that are shared
  # across different modules of homenix.

  config = mkIf config.programs.homenix.enable {
    home = {
      file = mkIf (cfg.enable && config.programs.homenix.enable && pkgs.stdenv.isLinux) {
        ".config/homenix/bin/launch-or-focus-tui".source = ../bin/launch-or-focus-tui;
        ".config/homenix/bin/launch-floating".source = ../bin/launch-floating;
        ".config/homenix/bin/omarchy-launch-webapp".source = ../bin/omarchy-launch-webapp;
        ".config/homenix/bin/omarchy-webapp-remove".source = ../bin/omarchy-webapp-remove;
        ".config/homenix/bin/omarchy-webapp-install".source = ../bin/omarchy-webapp-install;
      };

      activation.setupHomenixConfigFolder = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        mkdir -p ~/.config/homenix/current
      '';
    };
  };
}
