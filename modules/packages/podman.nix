{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.packages;

  # Replicates NixOS's virtualisation.podman.dockerCompat —
  # a real symlink on PATH, not a shell alias.
  dockerCompat = pkgs.runCommand "podman-docker-compat-${pkgs.podman.version}" {
    meta = pkgs.podman.meta // { outputsToInstall = [ "out" ]; };
    preferLocalBuild = true;
  } ''
    mkdir -p $out/bin
    ln -s ${pkgs.podman}/bin/podman $out/bin/docker
  '';

in

{
  config = mkIf (cfg.enable && config.programs.homenix.enable) {
    home.packages = [
      pkgs.podman
      dockerCompat
    ];

    # On macOS, podman machine exposes its socket under $TMPDIR.
    # Setting DOCKER_HOST lets lazydocker, testcontainers, and other
    # Docker-aware tools find the podman socket automatically.
    home.sessionVariables = lib.mkIf pkgs.stdenv.isDarwin {
      DOCKER_HOST = "unix://\$TMPDIR/podman/podman-machine-default-api.sock";
    };
  };
}
