{
  lib,
  config,
  ...
}:

with lib;

let

  enabled = (config.programs.homenix.enable && config.programs.homenix.nvim.enable);

in
{
  config = mkIf enabled {
    programs.nixvim.plugins = {
      copilot-lua.settings = {
        suggestion = {
          enabled = false;
        };
        panel = {
          layout = {
            position = "bottom";
            ratio = 0.2;
          };
        };
      };

      avante.settings = {
        provider = "claude-code";
      };
    };
  };
}
