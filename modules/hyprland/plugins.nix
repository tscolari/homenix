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
  options.programs.homenix.hyprland.plugins.hyprspace = {
    enable = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Enable the Hyprspace workspace-overview plugin";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.hyprlandPlugins.hyprspace;
      description = "Hyprspace plugin package (must be built against the running Hyprland)";
    };
  };

  config = mkIf (config.programs.homenix.enable && cfg.enable && cfg.plugins.hyprspace.enable) {
    wayland.windowManager.hyprland.plugins = [ cfg.plugins.hyprspace.package ];
  };
}
