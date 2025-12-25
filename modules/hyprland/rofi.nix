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

in
{
  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    programs.rofi = {
      enable = true;
      package = (nixGLWrapIfReq pkgs.rofi);

      # do not generate config file. Home-manager version is not flexible enough.
      configPath = "/dev/null";
    };

    home.file = {
      ".config/rofi/shared".source = ../../configs/rofi/shared;
      ".config/rofi/config.rasi".source = ../../configs/rofi/config.rasi;
      ".config/rofi/config-wallpaper.rasi".source = ../../configs/rofi/config-wallpaper.rasi;
    };
  };
}
