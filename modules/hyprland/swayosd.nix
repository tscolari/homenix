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
  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    services.swayosd = {
      enable = true;
      # topMargin = 0.9;
    };

    systemd.user.services.swayosd.Service.ExecStart = mkForce [
      "" # Clear existing ExecStart
      "${config.services.swayosd.package}/bin/swayosd-server --hide-caps-lock-led"
    ];

    home.file = {
      ".config/swayosd/config.toml".source = ../../configs/swayosd/config.toml;
      ".config/swayosd/style.css".source = ../../configs/swayosd/style.css;
    };
  };
}
