{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.homenix.zed;
  enabled = config.programs.homenix.enable && cfg.enable;
  supported = pkgs.homenix ? zed-editor;

  # GUI applications need a nixGL wrapper on non-NixOS Linux hosts. Home
  # Manager's wrapper is absent on NixOS and is never needed on Darwin.
  nixGLWrapIfNeeded =
    package:
    if pkgs.stdenv.isLinux && config.lib ? nixGL then config.lib.nixGL.wrap package else package;

  zedGciFormat = pkgs.writeShellApplication {
    name = "zed-gci-format";
    runtimeInputs = [
      pkgs.gci
      pkgs.go
    ];
    text = ''
      if [[ $# -ne 1 || -z "$1" ]]; then
        echo "usage: zed-gci-format <go-file>" >&2
        exit 2
      fi

      file="$1"
      directory="$(dirname -- "$file")"
      module_prefix="$(cd "$directory" && go list -m -f '{{.Path}}' 2>/dev/null || true)"

      args=(write --skip-generated -s standard -s default)
      if [[ -n "$module_prefix" ]]; then
        args+=(-s "prefix($module_prefix)")
      fi

      exec gci "''${args[@]}" "$file"
    '';
  };

  languagePackages = with pkgs; [
    delve
    docker-language-server
    gci
    golangci-lint
    golangci-lint-langserver
    gopls
    lua-language-server
    nil
    nixd
    postgres-language-server
    terraform-ls
    typescript-language-server
    vscode-langservers-extracted
    yaml-language-server
    zedGciFormat
  ];

  normalMode = "Editor && vim_mode == normal && !menu";
  visualMode = "Editor && vim_mode == visual && !menu";
in
{
  options.programs.homenix.zed.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.programs.homenix.enableAllByDefault;
    description = "Enable the Zed editor configuration";
  };

  config = lib.mkIf enabled {
    assertions = [
      {
        assertion = supported;
        message = ''
          programs.homenix.zed is not supported on ${pkgs.stdenv.hostPlatform.system}.
          Zed's upstream flake currently supports x86_64-linux, aarch64-linux,
          x86_64-darwin, and aarch64-darwin.
        '';
      }
    ];

    home.packages = languagePackages;

    programs.zed-editor = {
      enable = true;
      package = if supported then nixGLWrapIfNeeded pkgs.homenix.zed-editor else null;
      defaultEditor = false;

      # Home Manager merges these baselines into the user's existing JSON/JSON5
      # files on activation instead of replacing user-created configuration.
      mutableUserSettings = true;
      mutableUserKeymaps = true;
      mutableUserTasks = true;
      mutableUserDebug = true;

      extensions = [
        "codebook"
        "dockerfile"
        "golangci-lint"
        "kanagawa-themes"
        "lua"
        "nix"
        "postgres-language-server"
        "sql"
        "terraform"
      ];

      userSettings = {
        auto_update = false;
        autosave = "off";
        base_keymap = "Zed";
        vim_mode = true;
        theme = "Kanagawa Wave";

        soft_wrap = "none";
        hard_tabs = false;
        tab_size = 4;
        vertical_scroll_margin = 5;
        current_line_highlight = "all";
        colorize_brackets = true;
        show_completions_on_input = true;
        show_completion_documentation = true;
        auto_signature_help = true;
        use_autoclose = true;
        use_auto_surround = true;
        format_on_save = "on";
        remove_trailing_whitespace_on_save = true;
        ensure_final_newline_on_save = true;
        restore_on_startup = "last_session";
        code_lens = "off";

        # Reuse one preview tab while browsing. Editing a file or explicitly
        # opening it with a double-click still promotes it to a persistent tab.
        preview_tabs = {
          enabled = true;
          enable_preview_from_project_panel = true;
          enable_preview_from_file_finder = true;
          enable_preview_from_multibuffer = true;
          enable_preview_multibuffer_from_code_navigation = true;
          enable_preview_file_from_code_navigation = true;
          enable_keep_preview_on_code_navigation = true;
        };

        gutter = {
          line_numbers = true;
          folds = true;
          breakpoints = true;
        };

        indent_guides = {
          enabled = true;
          coloring = "indent_aware";
        };

        diagnostics.inline = {
          enabled = true;
          update_debounce_ms = 150;
          padding = 4;
          max_severity = null;
        };

        git = {
          git_gutter = "tracked_files";
          inline_blame.enabled = false;
        };

        languages = {
          Go = {
            hard_tabs = false;
            tab_size = 4;
            format_on_save = "on";
            formatter = "language_server";
            code_actions_on_format."source.organizeImports" = true;
            language_servers = [
              "gopls"
              "golangci-lint"
              "..."
            ];
            debuggers = [ "Delve" ];
          };
          Nix.language_servers = [
            "nil"
            "!nixd"
            "..."
          ];
          Lua.language_servers = [
            "lua-language-server"
            "..."
          ];
          TypeScript.language_servers = [
            "typescript-language-server"
            "eslint"
            "..."
          ];
          TSX.language_servers = [
            "typescript-language-server"
            "eslint"
            "..."
          ];
          JavaScript.language_servers = [
            "typescript-language-server"
            "eslint"
            "..."
          ];
          JSX.language_servers = [
            "typescript-language-server"
            "eslint"
            "..."
          ];
          Terraform.language_servers = [
            "terraform-ls"
            "..."
          ];
          YAML = {
            language_servers = [
              "yaml-language-server"
              "..."
            ];
            # Keep completion and schema support while hiding diagnostics that
            # produce false positives in Helm templates.
            diagnostics_max_severity = "off";
          };
          Dockerfile.language_servers = [
            "docker-language-server"
            "..."
          ];
          SQL.language_servers = [
            "postgres-language-server"
            "..."
          ];
        };

        lsp = {
          gopls = {
            binary = {
              path = lib.getExe pkgs.gopls;
              arguments = [ "-remote=auto" ];
              env.GOMEMLIMIT = "6GiB";
            };
            initialization_options = {
              gofumpt = false;
              semanticTokens = true;
              experimentalPostfixCompletions = true;
              analyses = {
                unusedparams = true;
                unusedwrite = true;
                shadow = true;
              };
              staticcheck = true;
              codelenses = {
                gc_details = false;
                generate = false;
                regenerate_cgo = false;
                test = false;
                tidy = false;
                upgrade_dependency = false;
                vendor = false;
              };
            };
          };

          "golangci-lint" = {
            binary.path = lib.getExe pkgs.golangci-lint-langserver;
            # nixpkgs carries golangci-lint v2, whose JSON output flags differ
            # from the v1 defaults used by older versions of the extension.
            initialization_options.command = [
              (lib.getExe pkgs.golangci-lint)
              "run"
              "--output.json.path"
              "stdout"
              "--show-stats=false"
              "--output.text.path="
            ];
          };
          nil.binary.path = lib.getExe pkgs.nil;
          nixd.binary.path = lib.getExe pkgs.nixd;
          "lua-language-server".binary.path = lib.getExe pkgs.lua-language-server;
          "terraform-ls".binary.path = lib.getExe pkgs.terraform-ls;
          "yaml-language-server" = {
            binary.path = lib.getExe pkgs.yaml-language-server;
            settings.yaml = {
              keyOrdering = false;
              schemas = {
                "https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json" =
                  "docker-compose.yml";
                "https://json.schemastore.org/chart.json" = "Chart.yaml";
              };
            };
          };
          "docker-language-server".binary = {
            path = lib.getExe pkgs.docker-language-server;
            arguments = [
              "start"
              "--stdio"
            ];
          };
          "typescript-language-server".binary.path = lib.getExe pkgs.typescript-language-server;
          eslint.binary = {
            path = lib.getExe' pkgs.vscode-langservers-extracted "vscode-eslint-language-server";
            arguments = [ "--stdio" ];
          };
          "postgres-language-server".binary.path = lib.getExe pkgs.postgres-language-server;
        };
      };

      userKeymaps = [
        {
          context = normalMode;
          bindings = {
            "-" = "project_panel::ToggleFocus";
            "v v" = "pane::SplitRight";
            "s s" = "pane::SplitDown";
            "alt-q" = "pane::CloseActiveItem";
            "alt-p" = "editor::GoToPreviousDiagnostic";
            "alt-n" = "editor::GoToDiagnostic";
            "enter" = "workspace::Save";
            "shift-enter" = "workspace::SaveWithoutFormat";
            "ctrl-p" = "file_finder::Toggle";
            "shift-k" = "editor::Hover";
            "[ t" = "editor::GoToPreviousDiagnostic";
            "] t" = "editor::GoToDiagnostic";

            "g m" = "editor::GoToImplementation";
            "g h" = "editor::FindAllReferences";
            "g r" = "editor::FindAllReferences";
            "g shift-k" = "editor::ShowSignatureHelp";

            "space space s" = "projects::OpenRecent";
            "space space c" = "command_palette::Toggle";
            "space space a" = "theme_selector::Toggle";
            "space space h" = "zed::OpenKeymap";

            "space f f" = "file_finder::Toggle";
            "space f o" = "tab_switcher::Toggle";
            "space f m" = "projects::OpenRecent";
            "space f -" = "project_panel::ToggleFocus";
            "space f ." = "pane::AlternateFile";

            "space g s" = "git_panel::ToggleFocus";
            "space g b" = "git::Blame";
            "space g c" = "git_panel::ActivateHistoryTab";
            "space g k" = "git::Diff";

            "space h t" = "git::Diff";
            "space h s" = "git::StageRange";
            "space h p" = "editor::ToggleSelectedDiffHunks";
            "space h u" = "git::Restore";
            "space h shift-r" = [
              "git::RestoreFile"
              { skip_prompt = false; }
            ];
            "space h l" = "editor::BlameHover";
            "space h b" = "git::Blame";
            "space h a" = "editor::BlameHover";

            "space l a" = "editor::ToggleCodeActions";
            "space l =" = "editor::Format";
            "space l r" = "editor::Rename";
            "space l k" = "editor::Hover";
            "space l s" = "project_symbols::Toggle";
            "space l d" = "diagnostics::Deploy";
            "space l shift-d" = "diagnostics::Deploy";
            "space l t" = "outline_panel::ToggleFocus";

            "space b d" = "pane::CloseActiveItem";
            "space b l" = "pane::ActivateLastItem";
            "space b n" = "pane::ActivateNextItem";
            "space b p" = "pane::ActivatePreviousItem";
            "space b s" = "tab_switcher::Toggle";

            "space s g" = "pane::DeploySearch";
            "space s f" = "pane::DeploySearch";
            "space s l" = "tab_switcher::ToggleAll";
            "space s b" = "buffer_search::Deploy";
            "space s p" = [
              "pane::DeploySearch"
              { replace_enabled = true; }
            ];

            "space d u" = "debug_panel::ToggleFocus";
            "space d t" = "debugger::Start";
            "space d l t" = "debugger::Rerun";
            "space d r" = "debugger::Restart";
            "space d q" = "debugger::Stop";
            "space d d" = "debugger::Start";
            "space d c" = "debugger::Continue";
            "space d n" = "debugger::StepOver";
            "space d s" = "debugger::StepInto";
            "space d o" = "debugger::StepOut";
            "space d b" = "editor::ToggleBreakpoint";

            "space t t" = "task::Spawn";
            "space t f" = [
              "task::Spawn"
              { task_name = "Go: test current package"; }
            ];
            "space t s" = [
              "task::Spawn"
              { task_name = "Go: test workspace"; }
            ];
            "space t g" = "task::Spawn";
            "space t ." = "task::Rerun";

            "space r o" = "markdown::OpenPreviewToTheSide";
          };
        }
        {
          context = visualMode;
          bindings = {
            ">" = [
              "workspace::SendKeystrokes"
              "> g v"
            ];
            "<" = [
              "workspace::SendKeystrokes"
              "< g v"
            ];
            "p" = [
              "workspace::SendKeystrokes"
              ''" _ d shift-p''
            ];
            "shift-y" = [
              "workspace::SendKeystrokes"
              ''" + y''
            ];
          };
        }
        {
          context = "Dock";
          bindings = {
            "ctrl-w h" = "workspace::ActivatePaneLeft";
            "ctrl-w j" = "workspace::ActivatePaneDown";
            "ctrl-w k" = "workspace::ActivatePaneUp";
            "ctrl-w l" = "workspace::ActivatePaneRight";
          };
        }
      ];

      userTasks = [
        {
          label = "Go: test current package";
          command = lib.getExe pkgs.go;
          args = [
            "test"
            "."
          ];
          cwd = "$ZED_DIRNAME";
          save = "all";
          reveal = "always";
          use_new_terminal = false;
          allow_concurrent_runs = false;
        }
        {
          label = "Go: test workspace";
          command = lib.getExe pkgs.go;
          args = [
            "test"
            "./..."
          ];
          cwd = "$ZED_WORKTREE_ROOT";
          save = "all";
          reveal = "always";
          use_new_terminal = false;
          allow_concurrent_runs = false;
        }
        {
          label = "Jest: test current file";
          command = lib.getExe' pkgs.nodejs "npx";
          args = [
            "jest"
            "--runTestsByPath"
            "$ZED_FILE"
          ];
          cwd = "$ZED_WORKTREE_ROOT";
          save = "current";
          reveal = "always";
          use_new_terminal = false;
          allow_concurrent_runs = false;
        }
        {
          label = "Go: organize imports with gci";
          command = lib.getExe zedGciFormat;
          args = [ "$ZED_FILE" ];
          cwd = "$ZED_DIRNAME";
          save = "current";
          reveal = "no_focus";
          use_new_terminal = false;
          allow_concurrent_runs = false;
        }
      ];

      userDebug = [
        {
          label = "Go: debug current package";
          adapter = "Delve";
          request = "launch";
          mode = "debug";
          program = "$ZED_DIRNAME";
        }
        {
          label = "Go: debug current file";
          adapter = "Delve";
          request = "launch";
          mode = "debug";
          program = "$ZED_FILE";
        }
      ];
    };
  };
}
