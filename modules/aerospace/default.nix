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
  options.programs.homenix.aerospace = {
    enable = mkOption {
      type = types.bool;
      default = config.programs.homenix.enableAllByDefault;
      description = "Enable Aerospace configuration (MACOS)";
    };
  };

  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    programs.aerospace = {
      enable = true;
      launchd.enable = true;
    };
  };
}
