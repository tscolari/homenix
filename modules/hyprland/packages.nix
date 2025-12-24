{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.hyprland;

  nixGLWrapIfReq = pkg: if config.lib ? nixGL then config.lib.nixGL.wrap pkg else pkg;

  # Detect if we're on non-NixOS (nixGL is only needed on non-NixOS systems)
  isNixOS = config.programs.homenix.isNixOS;

  wifitui = pkgs.buildGoModule rec {
    pname = "wifitui";
    version = "latest";

    src = pkgs.fetchFromGitHub {
      owner = "shazow";
      repo = "wifitui";
      rev = "main";
      hash = "sha256-xFZ8NBK0rEaHuk4bH78owHNY6ZKDOzQv8Mhy0pGoEj0=";
    };

    vendorHash = "sha256-znA4bsmPUQHWPXdBObbEKe+yK95SFJK+tbdOlx+oLsw=";
  };

in
{
  config = mkIf cfg.enable {
    home.packages = lib.mkMerge [
      (
        with pkgs;
        [
          # nm-tray
          (nixGLWrapIfReq imv)
          (nixGLWrapIfReq swaybg)
          (nixGLWrapIfReq nwg-displays)
          (nixGLWrapIfReq nwg-look)
          (nixGLWrapIfReq quickshell)
          (nixGLWrapIfReq hyprsunset)
          (nixGLWrapIfReq swaynotificationcenter)

          bc
          bluetuith
          bluez
          brightnessctl
          btop
          calcure
          cliphist
          fastfetch
          fcitx5
          ffmpeg
          fontconfig
          grim
          imagemagick
          jq
          khal
          networkmanagerapplet
          polkit
          qt6Packages.qt6ct
          slurp
          # swappy
          swayosd
          uwsm
          wallust
          wifitui
          wiremix
          wl-clipboard
          xdg-terminal-exec
        ]
        ++ optionals (isNixOS) [
          xdg-desktop-portal
          xdg-desktop-portal-gtk
          xdg-desktop-portal-hyprland
        ]
      )
    ];
  };
}
