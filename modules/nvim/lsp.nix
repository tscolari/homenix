{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let

  enabled = (config.programs.homenix.enable && config.programs.homenix.nvim.enable);
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
        -- into other buffers or piles up duplicate autocommands. Also torn down on
        -- LspDetach once no remaining client supports documentHighlight: otherwise a
        -- gopls exit (daemon killed/restarted) leaves the CursorHold autocmd behind
        -- while golangci_lint_ls stays attached, and every CursorHold then errors with
        -- "method textDocument/documentHighlight is not supported by any server".
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
          vim.api.nvim_create_autocmd('LspDetach', {
            group = group,
            buffer = bufnr,
            callback = function(args)
              for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf, method = 'textDocument/documentHighlight' })) do
                if c.id ~= args.data.client_id then
                  return
                end
              end
              vim.lsp.util.buf_clear_references(args.buf)
              vim.api.nvim_clear_autocmds({ group = group, buffer = args.buf })
            end,
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
          # One gopls per Neovim session (no `-remote=auto` shared daemon): memory is
          # bounded per process by GOMEMLIMIT, released when the session closes, and
          # one gopls dying doesn't take down LSP in every other session.
          config.cmd = [
            "${pkgs.coreutils}/bin/env"
            "GOMEMLIMIT=6GiB"
            "gopls"
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
  };
}
