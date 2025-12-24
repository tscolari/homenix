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
    ./terminals
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

  # pamShim is only enabled on non-nixos environments.
  # It's required to allow hyprlock to authenticate using the PAM.
  config.pamShim.enable = (!config.programs.homenix.isNixOS);
}
