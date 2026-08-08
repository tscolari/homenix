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

  compiledaemon = pkgs.buildGo126Module {
    pname = "compiledaemon";
    version = "v0.0.4";

    src = pkgs.fetchFromGitHub {
      owner = "githubnemo";
      repo = "CompileDaemon";
      rev = "v1.4.0";
      hash = "sha256-gpyXy7FO7ZVXJrkzcKHFez4S/dGiijXfZ9eSJtNlm58=";
    };

    vendorHash = "sha256-UDPOeg8jQbDB+Fr4x6ehK7UyQa8ySZy6yNxS1xotkgA=";
  };

in

{
  config = mkIf (cfg.enable && config.programs.homenix.enable) {
    home.packages = [
      compiledaemon
      godevmcp
      # `work` — from worktool's own flake via homenix.overlays.default.
      pkgs.work
    ];
  };
}
