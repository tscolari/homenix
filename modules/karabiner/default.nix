{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.karabiner;

  # Bundle IDs of terminal emulators where Home/End should pass through
  # as native terminal escape sequences, not be remapped to Cmd+Arrow.
  defaultExcludedApps = [
    "^com\\.mitchellh\\.ghostty$"
    "^net\\.kovidgoyal\\.kitty$"
    "^com\\.googlecode\\.iterm2$"
    "^com\\.apple\\.Terminal$"
    "^dev\\.warp\\.Warp-Stable$"
    "^com\\.github\\.wez\\.wezterm$"
  ];

  excludedApps = defaultExcludedApps ++ cfg.extraExcludedApps;

  appCondition = {
    type = "frontmost_application_unless";
    bundle_identifiers = excludedApps;
  };

  # Home → Cmd+Left, End → Cmd+Right.  "optional": ["any"] passes through
  # held modifiers (Shift, Ctrl, …), so Shift+Home → Cmd+Shift+Left for
  # selection automatically — no extra rules needed.
  homeEndRules = [
    {
      description = "Home/End → beginning/end of line (except terminals)";
      manipulators = [
        {
          type = "basic";
          from = {
            key_code = "home";
            modifiers.optional = [ "any" ];
          };
          to = [
            {
              key_code = "left_arrow";
              modifiers = [ "left_command" ];
            }
          ];
          conditions = [ appCondition ];
        }
        {
          type = "basic";
          from = {
            key_code = "end";
            modifiers.optional = [ "any" ];
          };
          to = [
            {
              key_code = "right_arrow";
              modifiers = [ "left_command" ];
            }
          ];
          conditions = [ appCondition ];
        }
      ];
    }
  ];

  karabinerConfig = {
    global = {
      check_for_updates_on_startup = true;
      show_in_menu_bar = true;
      show_profile_name_in_menu_bar = false;
    };
    profiles = [
      {
        name = "Default";
        selected = true;
        simple_modifications = [ ];
        fn_function_keys = [ ];
        complex_modifications = {
          parameters = { };
          rules = homeEndRules ++ cfg.extraRules;
        };
        virtual_hid_keyboard.keyboard_type = "ansi";
        devices = [ ];
        parameters = { };
      }
    ];
  };

  configJSON = builtins.toJSON karabinerConfig;

in
{
  options.programs.homenix.karabiner = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Install Karabiner-Elements and deploy a configuration that remaps
        Home/End to beginning/end of line in non-terminal apps (Chrome,
        Electron, etc.).

        On first launch you will need to grant Input Monitoring and allow
        the system extension in System Settings → Privacy & Security.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.karabiner-elements;
      defaultText = literalExpression "pkgs.karabiner-elements";
      description = "Karabiner-Elements package to use.";
    };

    extraExcludedApps = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Additional bundle-identifier regexes for apps where Home/End should
        NOT be remapped (e.g. apps that already handle these keys natively).
        The built-in list already excludes Ghostty, Kitty, iTerm2, Apple
        Terminal, Warp, and WezTerm.
      '';
    };

    extraRules = mkOption {
      type = types.listOf types.attrs;
      default = [ ];
      description = "Additional Karabiner complex-modification rules appended after the Home/End rule.";
    };
  };

  config = mkIf (config.programs.homenix.enable && cfg.enable && pkgs.stdenv.isDarwin) {
    home.packages = [ cfg.package ];

    # Copy (not symlink) — Karabiner calls unlink() on karabiner.json before
    # writing, which destroys symlinks.  A copy survives and is overwritten
    # on the next home-manager activation.
    home.activation.karabinerConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "$HOME/.config/karabiner"
      run install -m 644 ${pkgs.writeText "karabiner.json" configJSON} \
          "$HOME/.config/karabiner/karabiner.json"
    '';
  };
}
