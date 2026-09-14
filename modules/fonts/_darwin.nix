{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.fonts;

in

{
  # Home-manager already handles macOS font discovery by copying font files
  # to ~/Library/Fonts/HomeManager/ during activation. No extra work needed.
  #
  # This file exists for parity with the _darwin.nix/_linux.nix convention
  # and as a place to add Darwin-specific font config later if needed.
  config = mkIf (config.programs.homenix.enable && cfg.enable && pkgs.stdenv.isDarwin) {
  };
}
