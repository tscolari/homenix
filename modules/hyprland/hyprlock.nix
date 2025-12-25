{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.hyprland;

  nixGLWrapIfReq = pkg: if config.lib ? nixGL then config.lib.nixGL.wrap pkg else pkg;

  # PamShim is only used on non-nixos hosts
  # It ensures that hyprlock can authenticate using the system's pam.
  pamShimPkg =
    pkg: if config.programs.homenix.isNixOS then pkg else config.lib.pamShim.replacePam pkg;

in
{
  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    programs.hyprlock = {
      enable = true;
      package = (nixGLWrapIfReq (pamShimPkg pkgs.hyprlock));

      settings = {
        source = "${config.home.homeDirectory}/.config/homenix/current/theme/hyprlock.conf";
        background = {
          color = "$color";
          path = "${config.home.homeDirectory}/.config/homenix/current/background";
          blur_passes = 3;
        };

        animations = {
          enabled = false;
        };

        input-field = {
          size = "650, 100";
          position = "0, 0";
          halign = "center";
          valign = "center";

          inner_color = "$inner_color";
          outer_color = "$outer_color";
          outline_thickness = 4;

          font_family = "JetBrainsMono Nerd Font";
          font_color = "$font_color";

          placeholder_text = "Enter Password";
          check_color = "$check_color";
          fail_text = "<i>$FAIL ($ATTEMPTS)</i>";

          rounding = 0;
          shadow_passes = 0;
          fade_on_empty = false;
        };

        auth = {
          "fingerprint:enabled" = true;
        };
      };
    };
  };
}
