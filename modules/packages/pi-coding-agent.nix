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

        theme = "dark";
      };
    };
  };
}
