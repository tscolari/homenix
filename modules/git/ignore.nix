{
  config,
  lib,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.git;

in
{
  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    home.file = {
      ".config/git/ignore".text = ''
        .DS_Store
        Thumbs.db
        .directory

        .claude
        .reviews

        .direnv
        .envrc
      '';
    };
  };
}
