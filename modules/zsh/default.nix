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
  imports = [
    ./env.nix
    ./prezto.nix
    ./fzf.nix
    ./aliases.nix
  ];

  options.programs.homenix.zsh = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable zsh Configurations";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra zsh configuration";
    };
  };

  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    home = {
      activation.createZshAutoLoadFolder = lib.hm.dag.entryAfter [ "setupHomenixConfigFolder" ] ''
        mkdir -p ~/.config/zsh
      '';
    };

    programs.zsh = {
      enable = true;

      defaultKeymap = "viins";

      initContent = lib.mkBefore ''
        if [ -e ~/.secrets ]; then
          source ~/.secrets
        fi

        # Goes to the root path of the git repository
        function cdg() { cd "$(git rev-parse --show-toplevel)" }

        # Makes git auto completion faster favouring for local completions
        __git_files () {
            _wanted files expl 'local files' _files
        }

        # emacs style
        bindkey '^a' beginning-of-line
        bindkey '^e' end-of-line

        set -o vi

        eval "$(fasd --init auto)"

        for config_file in $(ls -A $HOME/.config/zsh | grep -e '.zsh$')
        do
          source "$HOME/.config/zsh/$config_file"
        done

        for p in $(echo $NIX_PROFILES | tr " " "\n"); do
          GOPATH="$GOPATH:$p/share/go"
        done

        for p in $(echo $GOPATH | tr ":" "\n"); do
          PATH="$PATH:$p/bin"
        done

        ${cfg.extraConfig}
      '';
    };
  };
}
