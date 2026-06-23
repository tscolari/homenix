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
        # `hyprctl plugin load` is the only real plugin-loading mechanism (there is
        # no in-process Lua loader function — hl.plugin.<name> is just the
        # namespace a plugin populates with its own functions once it has loaded).
        # Run it from a systemd unit ordered after graphical-session.target rather
        # than from inside Hyprland's own hyprland.start Lua hook or a home-manager
        # `plugins` list (which both shell out to hyprctl from an exec-once/Lua
        # startup hook) — both race the IPC socket coming up and can silently
        # no-op. graphical-session.target (set by UWSM) only activates once
        # Hyprland and its socket are actually ready, same as every other
        # Hyprland-dependent service in services.nix.
        systemd.user.services.hyprexpo-plugin = {
          Unit = {
            Description = "Load the hyprexpo Hyprland plugin";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.hyprland}/bin/hyprctl plugin load ${cfg.plugins.hyprexpo.package}/lib/libhyprexpo.so";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
}
