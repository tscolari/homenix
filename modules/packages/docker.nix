{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.packages;

in

{
  config = mkIf (cfg.enable && config.programs.homenix.enable) {
    # macOS has no native container runtime, so the daemon lives in a Lima VM.
    # The home-manager module owns the package, writes ~/.colima/<profile>/colima.yaml,
    # exports DOCKER_HOST, and runs the VM as a launchd agent.
    #
    # On Linux the daemon is native and belongs to the system config
    # (virtualisation.docker), not here.
    services.colima = lib.mkIf pkgs.stdenv.isDarwin {
      enable = true;

      profiles.default = {
        isActive = true;
        isService = true;
        setDockerHost = true;

        # colima's own defaults are 2 CPU / 2GiB, which is too small for
        # anything real. Note that with vmType = vz the memory is reserved
        # from the host for as long as the VM is up.
        settings = {
          cpu = 8;
          memory = 12;
          disk = 100;
          vmType = "vz";
          runtime = "docker";
        };
      };
    };
  };
}
