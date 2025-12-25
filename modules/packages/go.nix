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
    version = "latest";

    src = pkgs.fetchFromGitHub {
      owner = "fpt";
      repo = "go-dev-mcp";
      rev = "main";
      hash = "sha256-xFZ8NBK0rEaHuk4bH78owHNY6ZKDOzQv8Mhy0pGoEj0=";
    };

    vendorHash = "sha256-znA4bsmPUQHWPXdBObbEKe+yK95SFJK+tbdOlx+oLsw=";

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
