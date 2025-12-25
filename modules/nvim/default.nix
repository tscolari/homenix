{
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
      default = true;
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
      '';
    };

    home.activation.createUserManagedFolder = lib.hm.dag.entryAfter [ "setupHomenixConfigFolder" ] ''
      mkdir -p ${cfg.userManagedFolder}
      if [ ! -f ${cfg.userManagedFolder}/theme.lua ]; then
        cat > ${cfg.userManagedFolder}/theme.lua << 'EOF'
        vim.g.lualine_theme = "catppuccin-frappe"
        vim.g.config_colorscheme = "catppuccin-frappe"
      EOF
      fi
    '';
  };
}
