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

  mywifitui = pkgs.buildGoModule rec {
    pname = "wifitui";
    version = "v0.10.0";

    src = pkgs.fetchFromGitHub {
      owner = "shazow";
      repo = "wifitui";
      rev = "v0.10.0";
      hash = "sha256-ZhVMcpua9foigtkaN4EFjugwrEwUBOkXGLIIAaq9+zs=";
    };

    vendorHash = "sha256-HZEE8bJC9bsSYmyu7NBoxEprW08DO5+uApVnyNkKgMk=";
  };

in
{
  config = mkIf (config.programs.homenix.enable && cfg.enable) {
    home.packages =
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
        (nixGLWrapIfReq johnny-reborn)

        bc
        bluetuith
        bluez
        brightnessctl
        btop
        calcure
        cliphist
        fastfetch
        # fcitx5
        ffmpeg
        fontconfig
        gnome-calendar
        grim
        imagemagick
        jq
        khal
        networkmanagerapplet
        polkit
        qt6Packages.qt6ct
        slurp
        # swappy
        uwsm
        wallust
        mywifitui
        wiremix
        wl-clipboard
        xdg-terminal-exec
      ]
      ++ optionals (isNixOS) [
        # xdg-desktop-portal
        # xdg-desktop-portal-gtk
        # xdg-desktop-portal-hyprland
      ];
  };
}
