{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.sketchybar;

in
{
  options.programs.homenix.sketchybar = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable SketchyBar (macOS). The OmniWM and AeroSpace modules turn this on
        by default when they are enabled.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.sketchybar;
      defaultText = literalExpression "pkgs.sketchybar";
      description = "SketchyBar package to use.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = ''
        Extra packages placed on the SketchyBar service PATH. Window manager
        modules add their CLI here (omniwmctl, aerospace) for front_app.sh.
      '';
    };

    workspaces.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Show the AeroSpace workspace indicator in the middle of the bar. The
        OmniWM module turns this off, since OmniWM draws its own workspace bar
        there.
      '';
    };
  };

  config = mkIf (config.programs.homenix.enable && cfg.enable && pkgs.stdenv.isDarwin) {
    programs.sketchybar = {
      enable = true;
      package = cfg.package;
      service.enable = true;

      # launchd agents get a minimal PATH, so anything the plugins shell out
      # to has to be named here explicitly. curl/osascript/pmset/networksetup/
      # open/route live in /usr/bin|/usr/sbin and are already present.
      extraPackages =
        with pkgs;
        [
          jq
          blueutil # bluetooth status/toggle — no native CLI
          coreutils # `timeout` — bounds blueutil/osascript calls that can hang
        ]
        ++ cfg.extraPackages;
    };

    home.packages = with pkgs; [
      sketchybar-app-font
      sbarlua
    ];

    # The config lives as plain files under configs/sketchybar. Colours are
    # sourced from ~/.config/homenix/current/theme/sketchybar.sh with fallbacks
    # baked into colors.sh, the same mechanism jankyborders uses.
    #
    # The plugin scripts must be committed with the executable bit set,
    # otherwise sketchybar can't exec them. mkForce so we own the tree even
    # though the HM module also writes a sketchybarrc.
    xdg.configFile."sketchybar" = mkForce {
      source = ../../configs/sketchybar;
      recursive = true;
    };

    # Nix-side options for the shell config, sourced first by sketchybarrc.
    xdg.configFile."sketchybar/options.sh".text = ''
      export SKETCHYBAR_WORKSPACES=${if cfg.workspaces.enable then "on" else "off"}
    '';
  };
}
