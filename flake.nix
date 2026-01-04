{
  description = "Home Manager modules for using on NixOS and stand-alone";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixneovimplugins = {
      url = "github:NixNeovim/NixNeovimPlugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pam_shim = {
      url = "github:Cu3PO42/pam_shim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs =
    {
      nixpkgs,
      nixneovimplugins,
      nixvim,
      pam_shim,
      hyprland,
      ags,
      ...
    }:

    {
      # Modules ##############################################################
      homeModules.default =
        { pkgs, lib, ... }:
        {
          imports = [
            nixvim.homeModules.nixvim
            ./modules
            ags.homeManagerModules.default
            pam_shim.homeModules.default
          ];

          programs.homenix.hyprland.package = lib.mkDefault (
            hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
          );

          programs.homenix.hyprland.portalPackage = lib.mkDefault (
            hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
          );
        };

      # Overlays ##############################################################
      overlays = {
        # Required for the nvim module.
        default = final: prev: {
          homenix.vimExtraPlugins = nixneovimplugins.packages.${final.stdenv.hostPlatform.system};
        };
      };
    };
}
