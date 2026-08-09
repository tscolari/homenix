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

    # opencode upstream ships its own flake (on `dev`, its default branch), and
    # releases far faster than nixpkgs tracks it. Consumed by the overlay below
    # so `pkgs.opencode` is pinned here and bumped with `nix flake update
    # opencode`, rather than riding whatever a nixpkgs channel happens to have.
    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nreviewer — Neovim branch-review browser. Ships its own flake, so the
    # plugin derivation lives upstream instead of being pinned by rev/hash in
    # modules/nvim/plugins/custom.nix. Tracks main; bump with `nix flake update
    # nreviewer`.
    nreviewer = {
      url = "github:tscolari/nreviewer";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # `work` — git worktree + tmux workspace manager. Ships its own flake, so
    # the package definition (git/tmux PATH wrapper, shell completions,
    # vendorHash) lives upstream instead of being duplicated here. Tracks main;
    # bump with `nix flake update worktool`.
    worktool = {
      url = "github:tscolari/worktool";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixneovimplugins,
      nixvim,
      pam_shim,
      ags,
      hyprexpo,
      opencode,
      nreviewer,
      worktool,
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
            nreviewer.homeManagerModules.default
          ];
        };

      # Overlays ##############################################################
      overlays = {
        default = final: prev: {
          # opencode straight from upstream's own flake. Only the `opencode`
          # package is taken, not their overlay wholesale — that one also
          # replaces `opencode-desktop`, which the packages module deliberately
          # pulls from nixpkgs-unstable for its darwin .app layout.
          opencode = opencode.packages.${final.stdenv.hostPlatform.system}.opencode;

          # From worktool's own flake. Consumed by modules/packages/go.nix.
          work = worktool.packages.${final.stdenv.hostPlatform.system}.default;

          # From nreviewer's own flake. A plain vim plugin derivation, consumed
          # by modules/nvim/plugins/default.nix.
          nreviewer = nreviewer.packages.${final.stdenv.hostPlatform.system}.default;

          homenix = {
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
