{
  config,
  lib,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.packages;

in

{
  config = mkIf (cfg.enable && config.programs.homenix.enable) {
    programs.lazygit = {
      enable = true;
    };
  };
}
