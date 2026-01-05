This is a Hyprland configuration repo/scripts.

This is a work in progress, and the end goal is to offer this configuration
as a home-manager module, for both NixOS and other distributions.

For other distributions, for packages that would require a nixGL wrapper we are going to use
the new home-manager built-in, and this strategy for example:

```
{config, pkgs, ...}:
let
nixGLWrapIfNeeded = pkg:
    if config.lib ? nixGL
    then config.lib.nixGL.wrap pkg
    else pkg;

in
{
    home.packages = with pkgs; [
        (nixGLWrapIfNeeded ghostty)
    ];
}
```

The goal is that those packages work in both nixos and other distros.
Also when those packages are enabled as part of a service, we need to
use the same `(nixGLWrapIfNeeded package-name)` in the service's `package = ` property.

If this is being worked on an ubuntu machine, you most likely will find the home-manager
setup in `~/.config/home-manager`.
If this is being worked on a nixos machine, you most likely will find the nix setup
in `~/.config/nixfiles`.

Preferences:
* Use uwsm for hyprland
* I want services that can be managed by systemd to be managed by systemd (--user, e.g. hypridle, hyprsunset, etc...)

This is not a GO project
