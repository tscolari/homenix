{
  lib,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.qt;

in
{
  options.programs.homenix.qt = {
    enable = mkOption {
      type = types.bool;
      default = config.programs.homenix.hyprland.enable;
      description = "Enable QT Configuration";
    };
  };

  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    qt = {
      enable = true;
    };
  };
}
