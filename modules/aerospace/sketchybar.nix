{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.aerospace;

in
{

  config = mkIf (config.programs.homenix.enable && cfg.enable) {

    programs.sketchybar = {
      enable = true;

      # Run sketchybar as a launchd user agent.
      # NOTE: if your home-manager revision doesn't expose `service`, drop this
      # block and manage a `launchd.agents.sketchybar` unit instead.
      service.enable = true;

      # These are shelled out to by the plugins and must be on the *service*
      # PATH (launchd agents get a minimal PATH). curl/osascript/pmset/
      # networksetup/open/route all live in /usr/bin|/usr/sbin and are already
      # present, so only the nix-provided tools need listing here.
      #
      # NOTE: if `extraPackages` isn't available in your HM revision, add these
      # to home.packages instead and set the agent PATH explicitly.
      extraPackages = with pkgs; [
        jq
        blueutil # bluetooth status/toggle — no native CLI
        cfg.package # spaces plugin calls `aerospace list-*`
      ];
    };

    home.packages = with pkgs; [
      sketchybar-app-font
      sbarlua
    ];

    # The actual config lives as plain files under configs/sketchybar (same
    # split as configs/hypr/*). Colours are sourced from
    # ~/.config/homenix/current/theme/sketchybar.sh with Catppuccin Mocha
    # fallbacks baked into colors.sh — identical mechanism to jankyborders.sh.
    #
    # `recursive = true` copies the whole tree; the plugin scripts must be
    # committed with the executable bit set (git update-index --chmod=+x ...),
    # otherwise sketchybar can't exec them.
    #
    # mkForce so we own the tree even if the HM module also writes a
    # sketchybarrc (mirrors the jankyborders bordersrc override).
    xdg.configFile."sketchybar" = mkForce {
      source = ../../configs/sketchybar;
      recursive = true;
    };
  };
}
