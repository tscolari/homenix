{
  pkgs,
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
    home = {
      sessionVariables = rec {
        PATH = "$HOME/.local/bin:$HOME/.npm-packages/bin:$PATH";
        VISUAL = lib.mkDefault "nvim";

        GREP_COLOR = "1;33";

        ELECTRON_DISABLE_SANDBOX = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";

        GOPATH = "$HOME/go:$GOPATH";
        GO111MODULE = "on";
        GOPRIVATE = "github.com/redpanda-data,github.com/tscolari";
      };
    };

    programs.zsh = {
      sessionVariables = {
        XDG_DATA_DIRS = "$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";

        # SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";

        NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
          pkgs.stdenv.cc.cc
        ];

        NIX_LD = builtins.readFile "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
      };
    };
  };
}
