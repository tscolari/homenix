{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.aerospace;

  baseSettings = {
    width = "5.0";
    hidpi = "off";
  };

in
{

  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    services.jankyborders = {
      enable = true;
      settings = baseSettings;
    };

    xdg.configFile."borders/bordersrc".source = mkForce (
      pkgs.writeShellScript "bordersrc" ''
        options=(
        ${lib.generators.toKeyValue { indent = "  "; } baseSettings})

        theme_options=()
        theme_file="$HOME/.config/homenix/current/theme/jankyborders.sh"

        if [[ -r "$theme_file" ]]; then
          source "$theme_file"
          options+=( "''${theme_options[@]}" )
        fi

        exec ${lib.getExe config.services.jankyborders.package} "''${options[@]}"
      ''
    );
  };
}
