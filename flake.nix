{
  description = "Home Manager modules for using on NixOS and stand-alone";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixneovimplugins = {
      url = "github:NixNeovim/NixNeovimPlugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
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

    # Workspace-overview plugin for the hyprland module (sandwichfarm/hyprexpo
    # fork — maintained, chases Hyprland 0.55, exposes the lua plugin API). Source
    # only; built from source in the overlay against pkgs.hyprland. Not in nixpkgs.
    hyprexpo = {
      url = "github:sandwichfarm/hyprexpo";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      nixneovimplugins,
      nixvim,
      pam_shim,
      ags,
      hyprexpo,
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
        default = final: prev: {
          homenix =
            {
              # Required for the nvim module.
              vimExtraPlugins = nixneovimplugins.packages.${final.stdenv.hostPlatform.system};
            }
            // final.lib.optionalAttrs final.stdenv.hostPlatform.isLinux {
              # hyprexpo workspace-overview plugin, built from source against
              # pkgs.hyprland so its ABI matches the running compositor. Consumed
              # by modules/hyprland/plugins.nix (overridable there).
              hyprexpo = final.hyprlandPlugins.mkHyprlandPlugin {
                pluginName = "hyprexpo";
                version = "unstable-${hyprexpo.shortRev or "dirty"}";
                src = hyprexpo;
                dontUseCmakeConfigure = true;
                buildInputs = [
                  final.pango
                  final.cairo
                  final.lua5_4
                ];
                installPhase = ''
                  runHook preInstall
                  mkdir -p $out/lib
                  mv hyprexpo.so $out/lib/libhyprexpo.so
                  runHook postInstall
                '';
                meta.description = "Workspace overview plugin for Hyprland (sandwichfarm hyprexpo fork)";
              };
            };
        };
      };

      # Lib ###################################################################
      lib.hyprlandMonitors = import ./lib/monitors.nix;
    };
}
