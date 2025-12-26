{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.terminals;

in

{
  options.programs.homenix.terminals = {
    enable = mkOption {
      type = types.bool;
      default = config.programs.homenix.enableAllByDefault;
      description = "Enable Termoinal Configurations";
    };
  };

  imports = [
    ./ghostty
    ./kitty
  ];
}
