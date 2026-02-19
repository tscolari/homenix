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

  godevmcp = pkgs.buildGoModule rec {
    pname = "godevmcp";
    version = "v0.1.6";

    src = pkgs.fetchFromGitHub {
      owner = "fpt";
      repo = "go-dev-mcp";
      rev = "v0.1.6";
      hash = "sha256-sDn0eNIcvmw373JkFQx1fACuKc0TikNMR71oF+fiqSc=";
    };

    vendorHash = "sha256-0V7+641G/MYQL1IQaFxrQIqJcTmUhGnO2eonujr56zg=";

    subPackages = [ "godevmcp" ];
  };

in

{
  config = mkIf (cfg.enable && config.programs.homenix.enable) {
    home.packages = [
      godevmcp
    ];
  };
}
