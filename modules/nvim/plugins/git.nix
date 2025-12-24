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
    programs.nixvim = {
      extraConfigLua = ''
        require('vgit').setup {
          keymaps = {
            ['n ]c'] = 'hunk_up',
            ['n [c'] = 'hunk_down',
          },
          settings = {
            authorship_code_lens = { enabled = false },
            live_blame = { enabled = false },
          },
        }
      '';
    };
  };
}
