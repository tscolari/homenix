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
  config = mkIf cfg.enable {
    programs.zsh = {
      prezto = {
        enable = true;

        pmodules = [
          "environment"
          "terminal"
          "editor"
          "history"
          "directory"
          "spectrum"
          "utility"
          "ssh"
          "fasd"
          "completion"
          "ruby"
          "rails"
          "git"
          "history-substring-search"
          "prompt"
          "syntax-highlighting"
        ];

        editor.keymap = "emacs";
        tmux.autoStartLocal = true;
      };
    };
  };
}
