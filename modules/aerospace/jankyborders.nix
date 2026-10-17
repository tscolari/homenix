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

    # Theme-change hook: homenix-themes runs every executable file in
    # ~/.config/homenix/hooks/themes/ after switching ~/.config/homenix/current/theme.
    # bordersrc sources the active theme's jankyborders.sh at service start, so
    # a switch only takes effect once the service re-sources it.
    home.file.".config/homenix/hooks/themes/jankyborders" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        if [[ "$(uname)" == "Darwin" ]] && command -v launchctl >/dev/null 2>&1; then
          label="org.nix-community.home.jankyborders"

          if launchctl print "gui/$UID/$label" >/dev/null 2>&1; then
            launchctl kickstart -k "gui/$UID/$label" >/dev/null 2>&1 || true
          fi
        fi
      '';
    };
  };
}
