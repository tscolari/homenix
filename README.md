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

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager";
    homenix = {
      url = "github:tscolari/homenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, homenix, home-manager, ... }: {
    homeConfigurations."user" = home-manager.lib.homeManagerConfiguration {

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ homenix.overlays.default ]; # Required for nvim module
      };


      modules = [
        homenix.homeModules.default

        {
            programs.homenix = {

              isNixOS = false; # If using on non-nixos (defaults to true)

              git = {
                enable = true;
                name = "Your commit name";
                email = "git@example.com";
                githubUser = "example";
              };

              firefox_profiles = {
                enable = true;
                package = pkgs.unstable.firefox;
              };

              packages = {
                enable = true;
                skipFirefox = true;
              };

              tmux.enable = true;
              zsh.enable = true;

              hyprland.enable = true;
              nvim.enable = true;
            };
        }

      ];
    };
  };
}
```
