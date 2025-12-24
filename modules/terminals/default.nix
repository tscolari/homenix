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
    enable = mkEnableOption "homenix terminals configuration";
  };

  imports = [
    ./ghostty
    ./kitty
  ];
}
