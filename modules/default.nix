{ lib, config, ... }:

with lib;

{
  imports = [
    ./non-nixos-compat.nix
    ./firefox_profiles
    ./git
    ./gnome
    ./hyprland
    ./nvim
    ./packages
    ./tmux
    ./zsh
  ];

  options.programs.homenix = {
    isNixOS = mkOption {
      type = types.bool;
      default = true;
      description = "Whether this is being installed in NixOS or generic Linux";
    };
  };

  config.pamShim.enable = (!config.programs.homenix.isNixOS);
}
