{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.hyprland;

in
{
  options.programs.homenix.hyprland.plugins.hyprexpo = {
    enable = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Enable the hyprexpo workspace-overview plugin";
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = ''
        hyprexpo plugin package, built against the running Hyprland.

        hyprexpo is not in nixpkgs (dropped upstream), so there is no default:
        supply a build, e.g. via `hyprlandPlugins.mkHyprlandPlugin` from the
        sandwichfarm/hyprexpo source. Hyprspace was dropped because its overview
        renderer is broken on Hyprland 0.55 (KZDKM/Hyprspace #207/#220/#235).
      '';
    };
  };

  config = mkIf (
    config.programs.homenix.enable
    && cfg.enable
    && cfg.plugins.hyprexpo.enable
    && cfg.plugins.hyprexpo.package != null
  ) {
    wayland.windowManager.hyprland.plugins = [ cfg.plugins.hyprexpo.package ];
  };
}
