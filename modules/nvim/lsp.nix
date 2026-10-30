{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let

  enabled = (config.programs.homenix.enable && config.programs.homenix.nvim.enable);

  # Home-manager's activation scripts run with a minimal, curated PATH (coreutils,
  # findutils, grep, sed, jq, ...) that does NOT include `pkill`. On Darwin it ships
  # as a system binary at a fixed path; on Linux/NixOS, nixpkgs' `procps` provides the
  # real procps-ng suite including `pkill` (its Darwin build is a POSIX `ps`/`top`
  # shim that lacks `pkill`/`pgrep` entirely, so it can't be used there).
  pkill = if pkgs.stdenv.isDarwin then "/usr/bin/pkill" else "${pkgs.procps}/bin/pkill";

in
{
  config = mkIf enabled {
    programs.nixvim = {
      # Copilot highlight color
      highlightOverride = {
        CmpItemKindCopilot = {
          fg = "#6CC644";
        };
      };

      plugins.lspkind.settings.symbol_map = {
        Copilot = "";
      };

      plugins.lspsaga.settings = {
        lightbulb = {
          enable = false;
        };
      };

      plugins.conform-nvim.settings = {
        # formatters_by_ft = {
        #   go = [
        #     # "gofmt"
        #     "goimports"
        #   ];
        # };
        # format_on_save = {
        #   async = false;
        #   timeout_ms = 3000;
        #   lsp_format = "fallback";
        # };
      };

      extraConfigLua = ''
        require("conform").setup({
          formatters_by_ft = {
            go = { "goimports", "gci" },
          },
          format_on_save = {
            async = false,
            timeout_ms = 3000,
            lsp_format = "fallback",
          },
          formatters = {
            gofumpt = {
              -- Avoid rewriting legacy octal literals while retaining gofumpt's other rules.
              prepend_args = { "-lang=go1.12" },
            },
            goimports = {
              command = "goimports",
            },
            gci = {
              command = "gci",
              args = function(self, ctx)
                local function get_go_module_prefix(startpath)
                  local go_mod = vim.fs.find("go.mod", { path = startpath, upward = true })[1]
                  if not go_mod then return nil end
                  for line in io.lines(go_mod) do
                    local mod = line:match("^module%s+(%S+)")
                    if mod then return mod end
                  end
                  return nil
                end

                local dir = vim.fs.dirname(ctx.filename)
                local prefix = get_go_module_prefix(dir)

                local args = { "write", "--skip-generated", "-s", "standard", "-s", "default" }
                if prefix then
                  table.insert(args, "-s")
                  table.insert(args, "prefix(" .. prefix .. ")")
                end
                table.insert(args, "$FILENAME")
                return args
              end,
              stdin = false,
            },
          },
        })
        vim.lsp.log.set_level("warn")

        vim.api.nvim_set_hl(0, "LspReferenceRead", { bold = true, bg = "LightYellow" })
        vim.api.nvim_set_hl(0, "LspReferenceText", { bold = true, bg = "LightYellow" })
        vim.api.nvim_set_hl(0, "LspReferenceWrite", { bold = true, bg = "LightYellow" })

        vim.diagnostic.config({
          underline = true,
          virtual_text = {
            spacing = 4,
            format = function(diagnostic)
              -- Only show the first line with virtualtext.
              return string.gsub(diagnostic.message, '\n.*', "")
            end,
          },
          signs = true,
          update_in_insert = false,
        })
      '';

      # `plugins.lsp.{onAttach,capabilities,preConfig}` only get wired up when
      # `plugins.lsp.enable = true`, which we never set (servers are declared via the
      # native `lsp.servers` below). Use the native equivalents instead: `lsp.onAttach`
      # runs unconditionally on `LspAttach`, and capabilities/root_markers move to
      # `lsp.servers."*".config` further down.
      lsp.onAttach = ''
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

        local opts = { noremap = true, silent = true, buffer = bufnr }

        -- LSP Mappings
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

        -- Set some keybinds conditional on server capabilities
        if client.server_capabilities.documentFormattingProvider then
          vim.keymap.set("n", "ff", vim.lsp.buf.format, opts)
        elseif client.server_capabilities.documentRangeFormattingProvider then
          vim.keymap.set("n", "ff", vim.lsp.buf.format, opts)
        end

        -- Highlight references to the symbol under the cursor, when the server supports
        -- it. Scoped to this buffer and cleared on every (re)attach, so it never leaks
        -- into other buffers or piles up duplicate autocommands (the previous version
        -- checked the non-existent `document_highlight` field instead of
        -- `documentHighlightProvider`, so this never actually ran; its "else" branch
        -- globally dropped `updatetime` to 5 and opened an unscoped diagnostic float on
        -- every `CursorHold` for every buffer attached to a server without document
        -- highlighting, e.g. golangci_lint_ls on every Go buffer. That fallback is
        -- dropped rather than fixed: diagnostics remain visible via underline/signs and
        -- `<space>e`, without a popup firing near the cursor constantly.
        if client.server_capabilities.documentHighlightProvider then
          local group = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = false })
          vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
          vim.api.nvim_create_autocmd('CursorHold', {
            group = group,
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd('CursorMoved', {
            group = group,
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
          })
        end
      '';

      lsp.servers = {
        "*".config = {
          root_markers = [
            ".git/"
            "go.mod"
          ];
          # Advertise cmp-nvim-lsp's capabilities (snippet support, etc.) to every
          # server, same as `require('cmp_nvim_lsp').default_capabilities()` used to do
          # via the now-unused `plugins.lsp.capabilities` hook.
          capabilities = {
            __raw = "require('cmp_nvim_lsp').default_capabilities()";
          };
        };

        dockerls = {
          enable = true;
          config.settings = {
            cmd = [
              "docker-language-server"
              "start"
              "--stdio"
            ];
          };
        };

        eslint.enable = true;
        golangci_lint_ls.enable = true;

        gopls = {
          enable = true;
          config.cmd = [
            "${pkgs.coreutils}/bin/env"
            "GOMEMLIMIT=6GiB"
            "gopls"
            "-remote=auto"
          ];
          config.settings = {
            gopls = {
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
                gc_details = false; # Disable expensive codelenses
                generate = false;
                regenerate_cgo = false;
                test = false;
                tidy = false;
                upgrade_dependency = false;
                vendor = false;
              };
            };
          };
        };

        lua_ls = {
          enable = true;
          config.settings = {
            Lua = {
              runtime = {
                version = "LuaJIT";
                path = {
                  __raw = "vim.split(package.path, ';')";
                };
              };
              diagnostics = {
                globals = [ "vim" ];
              };
              workspace = {
                library = {
                  __raw = ''
                    {
                      [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                      [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                    }
                  '';
                };
              };
            };
          };
        };

        nil_ls = {
          enable = true;
          # Fetch missing flake inputs without prompting on every open.
          config.settings.nil.nix.flake.autoArchive = true;
        };
        postgres_language_server.enable = true;
        buf_ls.enable = false;
        protols.enable = false;
        ruby_lsp.enable = false;

        rust_analyzer = {
          enable = false;
          config.settings = {
            rust-analyzer = {
              assist = {
                importGranularity = "module";
                importPrefix = "by_self";
              };
              cargo = {
                loadOutDirsFromCheck = true;
              };
              procMacro = {
                enable = true;
              };
            };
          };
        };

        terraformls = {
          enable = true;
          config.settings = {
            filetypes = [
              "terraform"
              "tf"
              "tfvars"
            ];
          };
        };

        ts_ls.enable = true;
        vimls.enable = true;

        yamlls = {
          enable = true;
          config.settings = {
            yaml = {
              keyOrdering = false;
              schemas = {
                "https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json" =
                  "docker-compose.yml";
                "https://json.schemastore.org/chart.json" = "Chart.yaml";
              };
            };
          };
        };
      };
    };

    # `gopls -remote=auto` (configured on the `gopls` server above) shares one
    # persistent daemon across every Neovim session. That daemon has no
    # built-in staleness protection: it reuses the same socket address
    # regardless of which gopls binary started it, and per upstream docs it
    # only shuts down after a full minute with zero connected clients -- which
    # rarely happens while any Neovim window with a Go buffer stays open. Left
    # alone across a generation bump (new gopls version) or just many days
    # across many worktrees, the daemon ends up serving a stale/mismatched
    # gopls binary while accumulating cache for every workspace it has ever
    # seen, degrading or breaking completions silently (see the "garbage
    # autocomplete" investigation -- an 8-day-old daemon reached 16GB RSS and
    # a single completion request took 30s and returned nothing).
    #
    # Unconditionally kill the daemon and any forwarder processes on every
    # activation, so the next `-remote=auto` invocation always starts fresh
    # with the gopls binary from the generation being activated. This costs a
    # one-time re-indexing delay (a few seconds per workspace) the next time
    # each open Go buffer is touched after a rebuild, which is a better trade
    # than silently running a degraded daemon for days. A live Neovim session
    # whose gopls client dies here needs a manual `:LspRestart` (or to reopen
    # the buffer) to reconnect.
    home.activation.restartStaleGopls = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkill} -f 'gopls .*-remote=auto' || true
      run ${pkill} -f 'gopls serve -listen' || true
    '';
  };
}
