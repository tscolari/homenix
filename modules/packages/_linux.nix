{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.packages;

  isNixOS = config.programs.homenix.isNixOS;

  nixGLWrapIfReq = pkg: if config.lib ? nixGL then config.lib.nixGL.wrap pkg else pkg;

in

{
  config = mkIf (cfg.enable && config.programs.homenix.enable && pkgs.stdenv.isLinux) {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };

    programs.distrobox.enable = true;

    home.packages =
      with pkgs;
      [
        # Add new Linux-only packages here
        (lib.hiPrio ruby)
        btop
        calibre
        distrobox
        gtop
        inxi
        inkscape-with-extensions
        kdePackages.qtwayland
        killall
        libsecret
        libsForQt5.qtstyleplugin-kvantum
        lyrebird
        mutter
        p11-kit
        pamixer
        pciutils
        pinta
        playerctl
        pmutils
        podman
        procps
        pstree
        slurp
        steam
        sysprof
        wl-clipboard
        wowup-cf

        # Linux-only UI
        (nixGLWrapIfReq cameractrls-gtk4)
        (nixGLWrapIfReq unstable.chromium)
        (nixGLWrapIfReq google-chrome)
        (nixGLWrapIfReq evince)
        (nixGLWrapIfReq satty)
        yaru-theme
      ]
      ++ lib.optional (!cfg.skipFirefox) (nixGLWrapIfReq pkgs.firefox)
      ++ lib.optionals isNixOS [
        gnome-keyring
      ];
  };
}
