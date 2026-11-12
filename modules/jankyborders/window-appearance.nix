# Tones down macOS Tahoe window decorations to sit under the square borders.
# Not jankyborders-specific; lives here until it moves to a macOS module of its
# own.
#
# Both keys are global and only apply to AppKit windows: Catalyst apps, some
# dialogs and Notification Center ignore them. Apps read them at launch, so
# running ones need a relaunch (or log out and back in).
{
  lib,
  pkgs,
  config,
  ...
}:

let

  cfg = config.programs.homenix.jankyborders;

in
{
  config = lib.mkIf (config.programs.homenix.enable && cfg.enable && pkgs.stdenv.isDarwin) {
    targets.darwin.defaults.NSGlobalDomain = {
      # Window corner radius (macOS 26.4+): 26 is Tahoe, 10 is Sequoia.
      NSConvolutionOverride1 = 5.0;

      # Sidebars sit flush with the window instead of floating on Liquid Glass.
      NSSplitViewItemSidebarDefaultsToFloatingAppearance = false;
    };
  };
}
