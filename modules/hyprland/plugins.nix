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
      default = pkgs.homenix.hyprexpo or null;
      defaultText = literalExpression "pkgs.homenix.hyprexpo";
      description = ''
        hyprexpo plugin package, built against the running Hyprland.

        Defaults to the homenix-provided build (`pkgs.homenix.hyprexpo`, added by
        homenix.overlays.default and compiled from the sandwichfarm/hyprexpo
        source against pkgs.hyprland). Override to supply your own build, e.g. if
        you run a different Hyprland. hyprexpo is not in nixpkgs (dropped
        upstream).
      '';
    };
  };

  config =
    mkIf
      (
        config.programs.homenix.enable
        && cfg.enable
        && cfg.plugins.hyprexpo.enable
        && cfg.plugins.hyprexpo.package != null
      )
      {
        wayland.windowManager.hyprland.plugins = [ cfg.plugins.hyprexpo.package ];
      };
}
