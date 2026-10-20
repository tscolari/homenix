{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let

  enabled = (config.programs.homenix.enable && config.programs.homenix.packages.oh-my-pi.enable);

  pluginsCfg = config.programs.homenix.packages.oh-my-pi.plugins;

  # Activation runs before the new home-manager profile is linked into
  # PATH, so `omp` isn't resolvable by bare name yet: call it by store path.
  ompBin = "${config.programs.omp.package}/bin/omp";

  # "owner/repo" -> `omp plugin marketplace add owner/repo`.
  marketplaceAddScript = concatMapStringsSep "\n" (
    repo: "${ompBin} plugin marketplace add ${repo} 2> /dev/null || true"
  ) (attrNames pluginsCfg);

  # Installs (or upgrades, if already present) every plugin listed under
  # each marketplace. `<marketplace>` in `<plugin>@<marketplace>` is the
  # repo's last path segment, matching what `omp plugin marketplace add`
  # registers it as.
  pluginInstallScript = concatStringsSep "\n" (
    concatLists (
      mapAttrsToList (
        repo: plugins:
        let
          marketplace = last (splitString "/" repo);
        in
        map (
          plugin:
          "${ompBin} plugin install --scope user ${plugin}@${marketplace} 2> /dev/null || ${ompBin} plugin upgrade --scope user ${plugin}@${marketplace}"
        ) plugins
      ) pluginsCfg
    )
  );

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

      plugins = mkOption {
        type = types.attrsOf (types.listOf types.str);
        default = {
          "anthropics/claude-plugins-official" = [
            "superpowers"
            "claude-security"
            "code-review"
            "code-simplifier"
            "coderabbit"
          ];
          "blader/humanizer" = [
            "humanizer"
          ];
        };
        description = ''
          Marketplaces to add, and the plugins to install from each one.

          Keys are "owner/repo" marketplace identifiers, passed to
          `omp plugin marketplace add`. Values are the plugin names to
          install (or upgrade, if already present) from that marketplace,
          via `omp plugin install --scope user <plugin>@<marketplace>`,
          where `<marketplace>` is the repo's last path segment (e.g.
          "claude-plugins-official" for "anthropics/claude-plugins-official").
        '';
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

    # Theme-change hook: same contract as the pi hook above -- homenix-themes
    # runs it on every switch, ompCurrentThemeLink runs it once at install.
    # PI_CODING_AGENT_DIR relocates ~/.omp/agent for omp too, config.yml and
    # agent.db included; homenix's vendored pi module only exports that
    # variable when configDir differs from ~/.pi/agent, which it doesn't
    # today, so hardcoding ~/.omp/agent here creates no collision. Setting
    # programs.pi-coding-agent.configDir would.
    home.file.".config/homenix/hooks/themes/omp" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # omp watches ~/.omp/agent/themes for an event named homenix.json and
        # re-reads that path. The link target never changes, so recreating the
        # link is what triggers the reload in an already-running omp session.
        if [[ -d "$HOME/.omp/agent" ]]; then
          mkdir -p ~/.omp/agent/themes
          ln -sfn ~/.config/homenix/current/theme/oh-my-pi.json ~/.omp/agent/themes/homenix.json
        fi
      '';
    };

    home.activation.ompCurrentThemeLink = lib.hm.dag.entryAfter [ "setupHomenixConfigFolder" ] ''
      if [[ -x ~/.config/homenix/hooks/themes/omp ]]; then
        ~/.config/homenix/hooks/themes/omp
      fi
    '';

    # omp's marketplace commands shell out to `git` by bare name; activation
    # runs before the new profile is on PATH, so it must be added here too.
    home.activation.ompMarketplaceSetup = lib.hm.dag.entryAfter [ "setupHomenixConfigFolder" ] ''
      export PATH="${config.programs.git.package}/bin:$PATH"

      ${marketplaceAddScript}

      ${ompBin} plugin marketplace update

      ${pluginInstallScript}
    '';
  };
}
