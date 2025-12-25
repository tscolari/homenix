{
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.programs.homenix.zsh;
in
{
  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;

      defaultCommand = "fd --hidden --exclude={.git,.idea,.vscode,.sass-cache,node_modules,build} --type f";
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--border"
      ];
    };
  };
}
