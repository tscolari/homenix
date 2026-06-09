{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

# GO packages to be installed

let

  cfg = config.programs.homenix.packages;

  godevmcp = pkgs.buildGoModule {
    pname = "godevmcp";
    version = "v0.1.6";

    src = pkgs.fetchFromGitHub {
      owner = "fpt";
      repo = "go-dev-mcp";
      rev = "v0.1.6";
      hash = "sha256-Fkdmoea+HtlBitUcW0+6UDVZxTyjSi8iW4SXPxKKz8Y=";
    };

    vendorHash = "sha256-0V7+641G/MYQL1IQaFxrQIqJcTmUhGnO2eonujr56zg=";

    subPackages = [ "godevmcp" ];
  };

  worktool = pkgs.buildGo126Module {
    pname = "worktool";
    version = "v0.0.3a";

    src = pkgs.fetchgit {
      url = "https://codeberg.org/tscolari/worktool.git";
      rev = "v0.0.3";
      hash = "sha256-5rMPQNLyqo9e5EY9S8f1RIoXq7gcyzDAx9mNhqKqi4U=";
    };

    vendorHash = "sha256-7K17JaXFsjf163g5PXCb5ng2gYdotnZ2IDKk8KFjNj0=";

    subPackages = [
      "cmd/work"
    ];

    postInstall = ''
      mkdir -p $out/share/zsh/site-functions
      $out/bin/work completion zsh > $out/share/zsh/site-functions/_work
    '';
  };

in

{
  config = mkIf (cfg.enable && config.programs.homenix.enable) {
    home.packages = [
      godevmcp
      worktool
    ];
  };
}
