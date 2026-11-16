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

The Zed module installs `pkgs.unstable.zed-editor`; its settings and keymap
track that release, so the consumer's `pkgs` must expose a nixpkgs-unstable
package set as `unstable`.

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
        overlays = [ homenix.overlays.default ]; # Required for the nvim and themes modules
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

## Amethyst on macOS

`programs.homenix.amethyst.enable` installs the centered master layout.
Command+Shift+1..9 and Command+Shift+[ / ] move the focused window between
native desktops through skhd. Ghostty can keep its hidden titlebar.

On a desktop using the centered layout, a moved window takes the middle
column, including on return visits. The column keeps its existing width, with
a 40% default on an empty desktop. Windows Amethyst floats (the `floating`
list, small windows) keep their own frame, and bsp or fullscreen desktops keep
Amethyst's placement. Zoom tiles like any other app.

The helper pauses Amethyst's mouse handling during its synthetic drag and
restores it afterward, so mouse and keyboard resizing stay available between
moves. Amethyst and skhd need Accessibility access; create the desktops in
Mission Control before using their shortcuts.

Layout and movement regression tests:

```sh
node --test configs/amethyst/*.test.cjs
```
