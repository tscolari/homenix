{
  config,
  lib,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.hyprland;

in
{
  config = mkIf cfg.enable {
    services.swayosd = {
      enable = true;
    };

    home.file = {
      ".config/swayosd/config.toml".source = ../../configs/swayosd/config.toml;
      ".config/swayosd/style.css".source = ../../configs/swayosd/style.css;
    };
  };
}
