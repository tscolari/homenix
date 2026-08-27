# SketchyBar for OmniWM.
#
# OmniWM draws its own workspace bar, which is better than the sketchybar
# workspace items the AeroSpace config uses, so this variant drops those and
# keeps sketchybar purely for status: Apple menu, focused window title, and the
# right-hand tray/bluetooth/wifi/volume/cpu/battery/weather/clock cluster.
#
# Only the three files that actually differ live in configs/sketchybar-omniwm;
# colours, icons, the Apple menu and every other plugin are linked straight from
# configs/sketchybar so the two window managers cannot drift apart.
#
# Layout is two stacked bars — sketchybar on the menu bar row, OmniWM's
# workspace bar directly below it. ./settings.nix reserves the combined height
# as gaps.outer.top, and imports the height constant from here.
{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.omniwm;

in
{
  options.programs.homenix.omniwm.sketchybar = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Run SketchyBar alongside OmniWM for status items. OmniWM's own workspace
        bar is configured separately in ./settings.nix and stays enabled either
        way; this only controls the status bar above it.
      '';
    };
  };

  config =
    mkIf (config.programs.homenix.enable && cfg.enable && cfg.sketchybar.enable && pkgs.stdenv.isDarwin)
      {
        programs.sketchybar = {
          enable = true;
          service.enable = true;

          # launchd agents get a minimal PATH, so anything the plugins shell out
          # to has to be named here explicitly.
          extraPackages = with pkgs; [
            jq
            blueutil # bluetooth status/toggle — no native CLI
            cfg.package # front_app.sh calls `omniwmctl query`
          ];
        };

        home.packages = with pkgs; [
          sketchybar-app-font
          sbarlua
        ];

        # Composed from two source trees rather than one recursive copy: the
        # three OmniWM-specific files override, everything else is shared with
        # the AeroSpace config. mkForce so we win over the sketchybar HM module's
        # own sketchybarrc.
        xdg.configFile = {
          "sketchybar/sketchybarrc" = mkForce {
            source = ../../configs/sketchybar-omniwm/sketchybarrc;
            executable = true;
          };
          "sketchybar/items.sh".source = ../../configs/sketchybar-omniwm/items.sh;
          "sketchybar/plugins/front_app.sh" = mkForce {
            source = ../../configs/sketchybar-omniwm/plugins/front_app.sh;
            executable = true;
          };

          "sketchybar/colors.sh".source = ../../configs/sketchybar/colors.sh;
          "sketchybar/icons.sh".source = ../../configs/sketchybar/icons.sh;
          "sketchybar/apple.sh".source = ../../configs/sketchybar/apple.sh;
        }
        // (
          # Every shared plugin except front_app.sh (overridden above with the
          # omniwmctl version) and aerospace.sh (the workspace selector, which
          # this variant drops entirely in favour of OmniWM's own bar).
          let
            dropped = [
              "front_app.sh"
              "aerospace.sh"
            ];
            shared = builtins.attrNames (builtins.readDir ../../configs/sketchybar/plugins);
            wanted = builtins.filter (n: !(builtins.elem n dropped)) shared;
          in
          builtins.listToAttrs (
            map (name: {
              name = "sketchybar/plugins/${name}";
              value = {
                source = ../../configs/sketchybar/plugins + "/${name}";
                executable = true;
              };
            }) wanted
          )
        );
      };
}
