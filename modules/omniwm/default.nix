{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.omniwm;

  baseSettings = import ./settings.nix { inherit lib; };

  settings = recursiveUpdate baseSettings cfg.extraSettings;

in
{
  options.programs.homenix.omniwm = {
    enable = mkOption {
      type = types.bool;
      default = config.programs.homenix.enableAllByDefault;
      description = "Enable OmniWM window manager configuration (macOS)";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../../pkgs/omniwm { };
      defaultText = literalExpression "pkgs.callPackage ../../pkgs/omniwm { }";
      description = ''
        OmniWM package to use. Defaults to this repo's own derivation, since
        OmniWM is not in nixpkgs.
      '';
    };

    extraSettings = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''
        {
          gaps.size = 8.0;
          borders.color = { red = 0.5; green = 0.5; blue = 0.5; alpha = 1.0; };
        }
      '';
      description = ''
        Settings merged recursively over the generated `settings.toml`.

        Note that OmniWM requires a complete settings file: it decodes every
        table unconditionally and silently falls back to its own defaults if any
        key is missing. Use this to *override* keys, never to replace a table
        wholesale. Float-typed keys must be given as Nix floats (`8.0`, not `8`).
      '';
    };
  };

  imports = [
    ./skhd.nix
    ./sketchybar.nix
  ];

  config = mkIf (config.programs.homenix.enable && cfg.enable && pkgs.stdenv.isDarwin) {
    assertions = [
      {
        assertion = !config.programs.homenix.aerospace.enable;
        message = ''
          programs.homenix.omniwm and programs.homenix.aerospace are both enabled.
          They are both macOS window managers and will fight over every window.
          Disable one of them.
        '';
      }
      (lib.hm.assertions.assertPlatform "programs.homenix.omniwm" pkgs lib.platforms.darwin)
    ];

    home.packages = [ cfg.package ];

    # OmniWM has its own "Start at Login" toggle, but launchd keeps the lifecycle
    # declarative and restarts the WM if it dies. Program rather than
    # ProgramArguments: it is a bundled app, launched by its real executable.
    launchd.agents.omniwm = {
      enable = true;
      config = {
        Program = "${cfg.package}/Applications/OmniWM.app/Contents/MacOS/OmniWM";
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/omniwm/omniwm.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/omniwm/omniwm.err.log";
      };
    };

    # force: OmniWM rewrites settings.toml in place whenever its GUI saves,
    # replacing this symlink with a regular file. Without force the next
    # activation aborts rather than re-linking.
    #
    # The trade-off (see OMNI-WM-PROJECT.md, D4): the monitor*Overrides tables are
    # keyed by physical display UUID and are therefore machine state, not
    # configuration. They are reset on every activation.
    xdg.configFile."omniwm/settings.toml" = {
      source = (pkgs.formats.toml { }).generate "omniwm-settings.toml" settings;
      force = true;
    };
  };
}
