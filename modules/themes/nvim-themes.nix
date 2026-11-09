{ pkgs }:

# Neovim colorscheme plugins per homenix theme.
#
# The themes module links each plugin into ~/.config/homenix/themes/<theme>/nvim/,
# and nvim puts ~/.config/homenix/current/theme/nvim/* on its runtimepath before
# applying the colorscheme named in that theme's neovim.lua. Every plugin a
# theme's neovim.lua needs (including dependencies) must be listed here.

let

  buildPlugin =
    args:
    pkgs.vimUtils.buildVimPlugin {
      pname = args.pname;
      version = args.rev;
      src = pkgs.fetchFromGitHub {
        owner = args.owner;
        repo = args.repo;
        rev = args.rev;
        hash = args.hash;
      };
      dependencies = args.dependencies or [ ];
      # Integration modules for plugins these themes don't depend on fail
      # nixpkgs' require check on purpose; they load only alongside those plugins.
      nvimSkipModules = args.nvimSkipModules or [ ];
    };

  aether-nvim = buildPlugin {
    pname = "aether.nvim";
    owner = "bjarneo";
    repo = "aether.nvim";
    rev = "567efb778534e11ee1072d4fe27178f705a27d8a";
    hash = "sha256-HXFkWD02sX+do+YLA7YsgbELJLXcnXIFWNeym5LjQ9k=";
  };

  ethereal-nvim = buildPlugin {
    pname = "ethereal.nvim";
    owner = "bjarneo";
    repo = "ethereal.nvim";
    rev = "a0ec73332e537228981b6a4f465cef82bb3e1d36";
    hash = "sha256-ME8kwb0GsnTzl5k2OQLO6FUl+jDMUNNGfY86PrXlwVs=";
    nvimSkipModules = [ "ethereal.groups.telescope" ];
  };

  hackerman-nvim = buildPlugin {
    pname = "hackerman.nvim";
    owner = "bjarneo";
    repo = "hackerman.nvim";
    rev = "d7699ce7639686b8f3a5ae108b496a32ee5c076d";
    hash = "sha256-hHn/VWDE9t1KJMyxs98hwIPqrQzcZemPal6gD2U6rCs=";
    dependencies = [ aether-nvim ];
  };

  matteblack-nvim = buildPlugin {
    pname = "matteblack.nvim";
    owner = "tahayvr";
    repo = "matteblack.nvim";
    rev = "a8a039f5d6189b28d76fa0221e64965efec7e996";
    hash = "sha256-tk8jTOf0gCqU22KKZPxqu24IdKmHxsZT0wPL+ssLeH0=";
  };

in
with pkgs.vimPlugins;
{
  catppuccin = [ catppuccin-nvim ];
  catppuccin-latte = [ catppuccin-nvim ];
  ethereal = [ ethereal-nvim ];
  everforest = [ pkgs.homenix.vimExtraPlugins.everforest-nvim-neanias ];
  flexoki-light = [ pkgs.homenix.vimExtraPlugins.flexoki-neovim-kepano ];
  gruvbox = [ gruvbox-nvim ];
  hackerman = [
    hackerman-nvim
    aether-nvim
  ];
  kanagawa = [ kanagawa-nvim ];
  matte-black = [ matteblack-nvim ];
  nord = [ nightfox-nvim ];
  osaka-jade = [ bamboo-nvim ];
  ristretto = [ monokai-pro-nvim ];
  rose-pine = [ rose-pine ];
  tokyo-night = [ tokyonight-nvim ];
}
