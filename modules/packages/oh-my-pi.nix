{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let

  enabled = (config.programs.homenix.enable && config.programs.homenix.packages.oh-my-pi.enable);

  yamlFormat = pkgs.formats.yaml { };

  # Seeded once, then omp owns the file. Only the theme slots are declared:
  # everything else stays on omp's own defaults and stays editable via /settings.
  seedConfig = yamlFormat.generate "omp-config.yml" {
    theme = {
      dark = "homenix";
      light = "homenix";
    };
  };

in

{

  options.programs.homenix.packages = {
    oh-my-pi = {
      enable = mkOption {
        type = types.bool;
        default = config.programs.homenix.enableAllByDefault;
        description = "Enable oh-my-pi (omp) configuration";
      };
    };
  };

  config = mkIf enabled {
    programs.omp = {
      enable = true;

      settings = {
        theme = {
          light = "homenix";
          dark = "homenix";
        };

        symbolPreset = "nerd";
        composer = {
          shape = "pi";
        };
      };
    };

    # Seed only if absent. omp rewrites config.yml itself under an advisory lock,
    # so it can't be a store symlink: the write fails with EACCES.
    home.activation.ompSeedConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e ~/.omp/agent/config.yml ]; then
        mkdir -p ~/.omp/agent
        install -m 600 ${seedConfig} ~/.omp/agent/config.yml
      fi
    '';

    # Same reasoning as piCurrentThemeLink: an activation link and not home.file,
    # because homenix-themes recreates it on every theme switch. Recreating it is
    # also what makes omp hot-reload - omp watches the themes directory for an
    # event named homenix.json.
    #
    # PI_CODING_AGENT_DIR relocates this whole directory for omp too, config.yml
    # and agent.db included. homenix's vendored pi module only exports that
    # variable when configDir differs from ~/.pi/agent, which it doesn't today,
    # so there's no collision. Setting programs.pi-coding-agent.configDir would
    # create one.
    home.activation.ompCurrentThemeLink = lib.hm.dag.entryAfter [ "setupHomenixConfigFolder" ] ''
      mkdir -p ~/.omp/agent/themes
      ln -sfn ~/.config/homenix/current/theme/pi.json ~/.omp/agent/themes/homenix.json
    '';
  };
}
