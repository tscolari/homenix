{

  pkgs,
  lib,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.nvim;
  enabled = (config.programs.homenix.enable && config.programs.homenix.nvim.enable);

in
{
  options.programs.homenix.nvim = {
    enable = mkOption {
      type = types.bool;
      default = config.programs.homenix.enableAllByDefault;
      description = "Enable Neovim Configuration";
    };

    userManagedFolder = mkOption {
      default = "~/.config/nvim/user";
      type = types.str;
      description = "autoloaded folder, writable to the user.";
    };
  };

  imports = [
    ./autocmds.nix
    ./dependencies.nix
    ./globals.nix
    ./keyboard.nix
    ./lsp.nix
    ./options.nix
    ./plugins
    ./spelling.nix
  ];

  config = mkIf enabled {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;

      luaLoader.enable = true;

      viAlias = true;
      vimAlias = true;

      performance = {
        byteCompileLua.enable = true;
        byteCompileLua.plugins = false;
        combinePlugins.enable = false;
      };

      # Make ~/.config/nvim/user/ a writable folder where
      # users can add files to be automatically loaded.
      extraConfigLua = ''
        -- Load user configuration files
        local user_config_dir = vim.fn.expand('${cfg.userManagedFolder}')

        -- Create the directory if it doesn't exist
        vim.fn.mkdir(user_config_dir, 'p')

        -- Load all .lua files from the user config directory
        local user_config_files = vim.fn.glob(user_config_dir .. '/*.lua', false, true)

        for _, file in ipairs(user_config_files) do
          local ok, err = pcall(dofile, file)
          if not ok then
            vim.notify('Error loading user config ' .. file .. ': ' .. err, vim.log.levels.ERROR)
          end
        end

        -- homenix theme: ~/.config/homenix/current/theme carries neovim.lua
        -- (colorscheme + optional setup), nvim/* (the colorscheme plugins) and
        -- light.mode on light themes. The nvim theme hook calls this again in
        -- every running instance after `homenix-themes set`.
        local homenix_theme_dir = vim.fn.expand('~/.config/homenix/current/theme')
        local homenix_theme_rtp = {}

        local function homenix_theme_warn(msg)
          vim.notify('homenix theme: ' .. msg, vim.log.levels.WARN)
        end

        function _G.HomenixApplyTheme()
          -- A colorscheme set in the user folder overrides the homenix theme.
          if vim.g.config_colorscheme then
            local ok, err = pcall(vim.cmd.colorscheme, vim.g.config_colorscheme)
            if not ok then
              homenix_theme_warn('failed to apply ' .. vim.g.config_colorscheme .. ': ' .. err)
            end
            return
          end

          -- Store paths, not the current/theme symlink, so the previous theme's
          -- plugins can still be removed after the symlink has moved.
          for _, path in ipairs(homenix_theme_rtp) do
            vim.opt.rtp:remove(path)
          end
          homenix_theme_rtp = vim.tbl_map(vim.fn.resolve, vim.fn.glob(homenix_theme_dir .. '/nvim/*', false, true))
          for _, path in ipairs(homenix_theme_rtp) do
            vim.opt.rtp:prepend(path)
          end

          local ok, theme = pcall(dofile, homenix_theme_dir .. '/neovim.lua')
          if not ok or type(theme) ~= 'table' or type(theme.colorscheme) ~= 'string' then
            homenix_theme_warn('no usable neovim.lua in ' .. vim.fn.resolve(homenix_theme_dir))
            return
          end

          vim.o.background = vim.fn.filereadable(homenix_theme_dir .. '/light.mode') == 1 and 'light' or 'dark'

          if theme.setup then
            local setup_ok, err = pcall(theme.setup)
            if not setup_ok then
              homenix_theme_warn('setup failed: ' .. err)
            end
          end

          local cs_ok, err = pcall(vim.cmd.colorscheme, theme.colorscheme)
          if not cs_ok then
            homenix_theme_warn('failed to apply ' .. theme.colorscheme .. ': ' .. err)
            vim.cmd.colorscheme('default')
          end
        end

        HomenixApplyTheme()
      '';
    };

    home.activation.createUserManagedFolder = lib.hm.dag.entryAfter [ "setupHomenixConfigFolder" ] ''
      mkdir -p ${cfg.userManagedFolder}
    '';

    # Theme-change hook: homenix-themes runs every executable file in
    # ~/.config/homenix/hooks/themes/ after switching ~/.config/homenix/current/theme.
    # New nvim instances read the theme at startup; this re-applies it in the
    # running ones through their RPC sockets ($XDG_RUNTIME_DIR on Linux,
    # $TMPDIR/nvim.$USER/* on macOS). vim.schedule keeps the colorscheme change
    # out of the RPC request, and the timeout skips sockets of hung instances.
    home.file.".config/homenix/hooks/themes/nvim" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        shopt -s nullglob
        tmp="''${TMPDIR:-/tmp}"
        for socket in "''${XDG_RUNTIME_DIR:-/nonexistent}"/nvim.* "''${tmp%/}/nvim.$USER"/*/nvim.*; do
          [[ -S "$socket" ]] || continue
          ${pkgs.coreutils}/bin/timeout 2 ${config.programs.nixvim.package}/bin/nvim --server "$socket" \
            --remote-expr "luaeval('vim.schedule(_G.HomenixApplyTheme)')" >/dev/null 2>&1 || true
        done
      '';
    };
  };
}
