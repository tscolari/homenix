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
    version = "v0.0.2";

    src = pkgs.fetchgit {
      url = "https://codeberg.org/tscolari/worktool.git";
      rev = "v0.0.2";
      hash = "sha256-FA3bRO64AB7xgfZPe2MNex9eW5ZOYRTii6migfGynbY=";
    };

    vendorHash = "sha256-7K17JaXFsjf163g5PXCb5ng2gYdotnZ2IDKk8KFjNj0=";

    subPackages = [
      "cmd/work"
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
