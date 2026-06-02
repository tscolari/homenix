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
    version = "v0.0.1";

    src = pkgs.fetchgit {
      url = "https://codeberg.org/tscolari/worktool.git";
      rev = "v0.0.1";
      hash = "sha256-9amsu741/4IWR+Eak4u7FP6JvD7w/G0wP6uMNVpEbG4=";
    };

    vendorHash = null;

    subPackages = [
      "cmd/work"
      "cmd/workend"
    ];
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
