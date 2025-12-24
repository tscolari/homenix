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
    version = "v0.8.0";

    src = pkgs.fetchFromGitHub {
      owner = "shazow";
      repo = "wifitui";
      rev = "v0.8.0";
      hash = "sha256-JFs+7MDc0/hIDrefSRLWXurwJvvpR7LHJmCvmO1lpHA=";
    };

    vendorHash = "sha256-SEQPc13cefzT8SyuD3UmNtTDgcrXUGTX54SBrnOHJJw=";
  };

in
{
  config = mkIf cfg.enable {
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
      ];
  };
}
