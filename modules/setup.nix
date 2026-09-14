{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

{
  # This contains the base homenix config folder.
  # This contains common configuration (like themes) that are shared
  # across different modules of homenix.

  config = mkIf config.programs.homenix.enable {
    home = {
      file = mkMerge [
        (mkIf pkgs.stdenv.isLinux {
          ".config/homenix/bin/launch-or-focus-tui".source = ../bin/launch-or-focus-tui;
          ".config/homenix/bin/launch-floating".source = ../bin/launch-floating;
          ".config/homenix/bin/omarchy-launch-webapp".source = ../bin/omarchy-launch-webapp;
          ".config/homenix/bin/omarchy-webapp-remove".source = ../bin/omarchy-webapp-remove;
          ".config/homenix/bin/omarchy-webapp-install".source = ../bin/omarchy-webapp-install;
        })

        # On macOS, remap Home/End to move to beginning/end of line instead of
        # beginning/end of document (the Linux-standard behaviour).
        # DefaultKeyBindings.dict is honoured by all Cocoa/AppKit text views
        # (Safari, Notes, Mail, most native apps).
        (mkIf pkgs.stdenv.isDarwin {
          "Library/KeyBindings/DefaultKeyBindings.dict".text = ''
            {
              "\UF729"  = moveToBeginningOfLine:;              /* Home */
              "\UF72B"  = moveToEndOfLine:;                    /* End */
              "$\UF729" = moveToBeginningOfLineAndModifySelection:; /* Shift-Home */
              "$\UF72B" = moveToEndOfLineAndModifySelection:;      /* Shift-End */
            }
          '';
        })
      ];

      activation.setupHomenixConfigFolder = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        mkdir -p ~/.config/homenix/current
      '';
    };
  };
}
