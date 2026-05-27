{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

{
  imports = [
    ./firefox_profiles
    ./git
    ./nvim
    ./setup.nix
    ./terminals
    ./tmux
    ./zsh
  ]
  ++ lib.optionals isLinux [
    ./gnome
    ./gtk
    ./hyprland
    ./non-nixos-compat.nix
    ./packages
    ./qt
  ];

  options.programs.homenix = {
    enable = mkEnableOption "Enable all homenix modules";

    isNixOS = mkOption {
      type = types.bool;
      default = true;
      description = "Whether this is being installed in NixOS or generic Linux (ignored on Darwin)";
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

  config = mkIf config.programs.homenix.enable (mkMerge [
    (mkIf pkgs.stdenv.isLinux {
      # pamShim is only enabled on non-nixos Linux environments.
      # It's required to allow hyprlock to authenticate using the PAM.
      # pam_shim module is not imported on Darwin so this option doesn't exist there.
      pamShim.enable = (!config.programs.homenix.isNixOS);
    })

    (mkIf pkgs.stdenv.isDarwin {
      # Linux-only modules default to disabled on Darwin.
      # gtk defaults to (hyprland.enable || gnome.enable) and qt defaults to hyprland.enable,
      # so they will also be false by cascade.
      programs.homenix.hyprland.enable = mkDefault false;
      programs.homenix.gnome.enable = mkDefault false;
    })
  ]);
}
