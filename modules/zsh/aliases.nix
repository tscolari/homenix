{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.zsh;

in
{
  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    programs.zsh = {
      initContent = lib.mkBefore (
        if pkgs.stdenv.isLinux then
          ''
            alias pbcopy="wl-copy";
            alias pbpaste="wl-paste -n";
            alias open="xdg-open";
          ''
        else
          ''
            # pbcopy/pbpaste/open are native on macOS
          ''
      );

      shellAliases = {
        # Bundler
        be = "bundle exec";
        bes = "bundle exec spec";

        # Tmux
        tx = "tmux";
        txa = "tmux attach -t";
        txn = "tmux new -s";
        txs = "tmux switch -t";

        # Show human friendly numbers and colours
        df = "df -h";
        ll = "ls -alGh --color";
        ls = "ls -Gh --color";
        du = "du -h -d 2";

        # Rspec
        rs = "rspec spec";

        weather = "curl wttr.in";

        vim = "nvim";

        # Override rm -i alias which makes rm prompt for every action
        rm = "nocorrect rm";

        # Don't try to glob with zsh so you can do
        # stuff like ga *foo* and correctly have
        # git add the right stuff
        git = "noglob git";
        gpr = "git pull --rebase";

        # Kubernetes
        k = "kubectl";
        kn = "kubens";
        kc = "kubectx";
        kg = "kubectl get";
        kd = "kubectl describe";

        # Worktool
        ws = "work start";
        wa = "work attach";
      };

      shellGlobalAliases = {
        C = "| wc -l";
        H = "| head";
        L = "| less";
        N = "| /dev/null";
        S = "| sort";
        G = "| grep";
      };
    };
  };
}
