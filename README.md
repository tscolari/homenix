# homenix

Home-manager modules for my desktop and shell setup. They started as a split of my NixOS configuration, and they now run in three places:

* NixOS, where the system config imports these modules for each user.
* Other Linux distributions, through standalone home-manager. Most companies restrict which distro I can use, and this keeps my setup working on whatever I get.
* macOS, through standalone home-manager as well.

Each module sits under `programs.homenix.<name>`. With `enableAllByDefault` (the default), enabling homenix turns on the modules that fit the platform. Linux-only modules like Hyprland and GNOME stay off on macOS, and the macOS ones stay off on Linux.

## Usage

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    homenix = {
      url = "github:tscolari/homenix/26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, homenix, home-manager, ... }: {
    homeConfigurations."user" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          homenix.overlays.default
          (final: prev: {
            unstable = import nixpkgs-unstable {
              system = final.stdenv.hostPlatform.system;
              config.allowUnfree = true;
            };
          })
        ];
      };

      modules = [
        homenix.homeModules.default
        {
          programs.homenix = {
            enable = true;
            isNixOS = false; # defaults to true, ignored on macOS

            # git = {
            #   name = "Your commit name";
            #   email = "git@example.com";
            #   githubUser = "example";
            # };

            # Turn everything off and opt in module by module instead:
            # enableAllByDefault = false;
            # zsh.enable = true;
            # nvim.enable = true;
          };
        }
      ];
    };
  };
}
```

Both overlays are required. `homenix.overlays.default` provides the nvim plugin set, the hyprexpo plugin and `work`. Several modules (Zed, Ghostty, Chromium) track nixpkgs-unstable releases and read them from `pkgs.unstable`.

## Linux

Hyprland runs as a UWSM session, and its helpers (waybar, hypridle, hyprsunset and the rest) run as systemd user services.

### Quick start

* Super+Enter opens a terminal.
* Super+Shift+B opens the browser.
* Super+Shift+F opens the file manager.
* Super+Shift+E opens a settings menu with most of the day-to-day system configuration: themes, wallpapers, animations, monitor profiles, power profiles, hyprsunset, the master/dwindle toggle, game mode, GTK and Qt settings, and a keybind search for everything else.

On non-NixOS machines, set `isNixOS = false`. This enables `pam_shim` for hyprlock and adds the system XDG, GSettings and GI paths that GTK apps expect. GPU apps get wrapped through home-manager's nixGL support when it is configured:

```nix
targets.genericLinux.nixGL.packages = nixgl.packages;
```

Monitor layouts are defined as presets and switched at runtime. `homenix.lib.hyprlandMonitors` has the ones I use, and they double as examples:

```nix
programs.homenix.hyprland.presetMonitors = with homenix.lib.hyprlandMonitors; [
  laptop-home
  {
    name = "Desk";
    config = ''hl.monitor({ output = "DP-1", mode = "2560x1440@144", position = "0x0", scale = 1 })'';
  }
];
```

## macOS

Amethyst is the window manager (`programs.homenix.amethyst`) and is on by default. The setup tries to mimic the Hyprland one as closely as macOS allows, from the centered master layout to the keybindings and the bar. It brings sketchybar, JankyBorders and skhd along with it. Command+Shift+1..9 and Command+Shift+[ / ] move the focused window between native desktops through skhd. A window moved to a centered desktop takes the middle column and keeps that column's width (40% on an empty desktop). Floating windows and bsp or fullscreen desktops keep Amethyst's own placement. Amethyst and skhd need Accessibility access, and the desktops have to exist in Mission Control before the shortcuts work.

The layout and movement logic has tests:

```sh
node --test configs/amethyst/*.test.cjs
```

## Themes

The themes module installs 14 themes into `~/.config/homenix/themes` and starts on kanagawa. `homenix-themes set <name>` switches between them, and a picker (rofi on Linux, `choose` on macOS) wraps it.

A theme covers Hyprland, hyprlock, waybar, rofi, swayosd, swaync, sketchybar, JankyBorders, Ghostty, Kitty, btop, Neovim, Zed, pi, oh-my-pi and the wallpaper.

Most of these reload on their own. Neovim, Zed, JankyBorders, pi and oh-my-pi each install a hook under `~/.config/homenix/hooks/themes` that applies the theme in place, and on Linux the picker also reloads Hyprland, waybar and swaync. The terminals and btop pick it up the next time they load their config.
