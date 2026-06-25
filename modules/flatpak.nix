{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.homenix.flatpak;
in
{
  options.programs.homenix.flatpak = {
    enable = mkOption {
      type = types.bool;
      default = config.programs.homenix.enableAllByDefault;
      description = "Manage default Flatpak sandbox overrides";
    };
  };

  config = mkIf (cfg.enable && config.programs.homenix.enable && pkgs.stdenv.isLinux) {
    # Flathub apps commonly only request the x11 socket. Under a pure
    # Wayland compositor (no XWayland fallback path) that leaves them
    # unable to open a window at all. This is unioned with each app's
    # own permissions (and any per-app `flatpak override`), so it just
    # adds Wayland access without taking anything away.
    xdg.dataFile."flatpak/overrides/global".text = ''
      [Context]
      sockets=wayland;
    '';
  };
}
