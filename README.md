# My nix home-manager modules

This is an attempt to decouple my original nix configuration, splitting home-manager into individual modules.
As most organization have restrictions on which Linux distribution are allowed, I hope with this
allow most of my packages and configurations to work free at any other distro by using home-manager when necessary,
and still be fully compatible with my original NixOS configuration/machine.

* NixOS machines:
  * Set all things nix, and includes these home-manager modules for the user(s).
* Non-NixOS machines:
  * Have only home-manager configured and include these modules to install/setup configurations.

# Usage Example

The Zed module uses the package from Zed's upstream flake. Nix does not inherit
`nixConfig` from dependency flakes, so consumers that enable Zed should add its
binary cache to their root flake (or configure it system-wide):

```nix
nixConfig = {
  extra-substituters = [ "https://zed.cachix.org" ];
  extra-trusted-public-keys = [
    "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
  ];
};
```

Without these settings, Nix may build Zed's large Rust dependency graph locally.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager";
    homenix = {
      url = "github:tscolari/homenix/26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, homenix, home-manager, ... }: {
    homeConfigurations."user" = home-manager.lib.homeManagerConfiguration {

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ homenix.overlays.default ]; # Required for nvim and Zed modules
      };


      modules = [
        homenix.homeModules.default

        {
            programs.homenix = {
              enable = true;
              isNixOS = false; # If using on non-nixos (defaults to true)

              enableAllByDefault = true; # (true by default)

              # git = {
              #   enable = true;
              #   name = "Your commit name";
              #   email = "git@example.com";
              #   githubUser = "example";
              # };

              # firefox_profiles = {
              #   enable = true;
              #   package = pkgs.unstable.firefox;
              # };

              # packages = {
              #   enable = true;
              #   skipFirefox = true;
              # };

              # tmux.enable = true;
              # zsh.enable = true;

              # hyprland.enable = true;
              # nvim.enable = true;
              # zed.enable = true;
            };
        }

      ];
    };
  };
}
```
