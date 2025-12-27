{ lib, config, ... }:

with lib;

{
  imports = [
    ./firefox_profiles
    ./git
    ./gnome
    ./gtk
    ./hyprland
    ./non-nixos-compat.nix
    ./nvim
    ./packages
    ./setup.nix
    ./terminals
    ./tmux
    ./zsh
  ];

  options.programs.homenix = {
    enable = mkEnableOption "Enable all homenix modules";

    isNixOS = mkOption {
      type = types.bool;
      default = true;
      description = "Whether this is being installed in NixOS or generic Linux";
    };

    enableAllByDefault = mkOption {
      type = types.bool;
      default = true;
      description = ''
        This will enable all modules automatically when homenix is enabled.
        Disabling will allow/require each individual module to be enabled.
      '';
    };
  };

  config = mkIf config.programs.homenix.enable {
    # pamShim is only enabled on non-nixos environments.
    # It's required to allow hyprlock to authenticate using the PAM.
    pamShim.enable = (!config.programs.homenix.isNixOS);
  };
}
