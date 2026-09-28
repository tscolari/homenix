{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let

  enabled = (
    config.programs.homenix.enable && config.programs.homenix.packages.pi-coding-agent.enable
  );

in

{

  options.programs.homenix.packages = {
    pi-coding-agent = {
      enable = mkOption {
        type = types.bool;
        default = config.programs.homenix.enableAllByDefault;
        description = "Enable pi-coding-agent configuration";
      };
    };
  };

  config = mkIf enabled {
    # Follows configDir (pi's ~/.pi/agent default) so the extension can never
    # end up in a directory pi isn't reading.
    home.file."${config.programs.pi-coding-agent.configDir}/extensions/provider-base-urls.ts".source =
      ../../configs/pi/extensions/provider-base-urls.ts;

    # Deliberately an activation link rather than home.file: homenix-themes
    # recreates it on every theme switch, which would otherwise conflict with
    # home-manager ownership. Recreating it is also what makes pi hot-reload --
    # pi watches the themes directory for an event named <activeTheme>.json.
    home.activation.piCurrentThemeLink = lib.hm.dag.entryAfter [ "setupHomenixConfigFolder" ] ''
      mkdir -p "${config.programs.pi-coding-agent.configDir}/themes"
      ln -sfn ~/.config/homenix/current/theme/pi.json "${config.programs.pi-coding-agent.configDir}/themes/homenix.json"
    '';

    programs.pi-coding-agent = {
      enable = true;
      context = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.AGENTS.md";
      package = pkgs.master.pi-coding-agent;
      keybindings = { };
      settings = {
        compaction = {
          enabled = true;
          keepRecentTokens = 20000;
          reserveTokens = 16384;
        };

        packages = [
          "npm:@termdraw/pi"
          "npm:pi-mcp-adapter"
          "npm:pi-subagents"
          "npm:pi-web-access"
          "npm:pi-background-tasks"
          "npm:pi-goal-x"
          "npm:pi-claude-bridge"
          "npm:context-mode"
          "npm:@gotgenes/pi-permission-system"
          "npm:@narumitw/pi-btw"
          "npm:@narumitw/pi-plan-mode"
        ];

        # Resolves through ~/.pi/agent/themes/homenix.json -> the active
        # homenix theme's pi.json, so pi follows the desktop theme.
        theme = "homenix";
      };
    };
  };
}
