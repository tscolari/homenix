{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.jankyborders;

  # borders only draws outside the window, and only half the width it is given:
  # the round style strokes `width` centred on the window edge, the square style
  # fills `width / 2` outward, and both clip away whatever falls inside the
  # window (border.c, drawing.h). Doubling it makes the option the visible
  # border width.
  #
  # Square, with unfocused windows borderless, as in Hyprland
  # (decorations.lua: inactive_border = rgba(00000000)). Themes only supply
  # active_color.
  baseSettings = {
    width = toString (cfg.width * 2);
    hidpi = "off";
    style = "round";
    inactive_color = "0x00000000";
  };

  bordersrc = pkgs.writeShellScript "bordersrc" ''
    options=(
    ${lib.generators.toKeyValue { indent = "  "; } baseSettings})

    theme_options=()
    theme_file="$HOME/.config/homenix/current/theme/jankyborders.sh"

    if [[ -r "$theme_file" ]]; then
      source "$theme_file"
      options+=( "''${theme_options[@]}" )
    fi

    exec ${lib.getExe config.services.jankyborders.package} "''${options[@]}"
  '';

in
{
  imports = [ ./window-appearance.nix ];

  options.programs.homenix.jankyborders = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Jankiborders (macOS)";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.jankyborders;
      defaultText = literalExpression "pkgs.jankyborders";
      description = "Jankyborders package to use.";
    };

    width = mkOption {
      type = types.float;
      default = 5.0;
      description = "Visible border width outside the window, in points.";
    };
  };

  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    services.jankyborders = {
      enable = true;
      package = cfg.package;
      settings = baseSettings;
    };

    xdg.configFile."borders/bordersrc".source = mkForce bordersrc;

    # The agent runs bordersrc itself, so borders starts with its options as
    # arguments. home-manager's default starts a bare `borders`, which forks
    # bordersrc and has it message the running instance. That loses the
    # options in two ways:
    #   - the agent's plist never changes when only the settings do, so
    #     home-manager never restarts it and new settings are ignored;
    #   - on a restart the forked bordersrc can reach the outgoing instance
    #     before it releases its mach port, leaving the new one on defaults.
    launchd.agents.jankyborders.config.ProgramArguments = mkForce [ "${bordersrc}" ];

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
