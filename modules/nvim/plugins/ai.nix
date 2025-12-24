{
  lib,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.nvim;

in
{
  config = mkIf cfg.enable {
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
