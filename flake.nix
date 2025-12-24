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
  };

  outputs =
    {
      nixpkgs,
      nixneovimplugins,
      nixvim,
      pam_shim,
      ags,
      ...
    }:

    {
      # Modules ##############################################################
      homeModules.default =
        { ... }:
        {
          imports = [
            nixvim.homeModules.nixvim
            ./modules
            ags.homeManagerModules.default
            pam_shim.homeModules.default
          ];
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
