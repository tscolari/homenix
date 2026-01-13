{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.hyprland;

  nixGLWrapIfReq = pkg: if config.lib ? nixGL then config.lib.nixGL.wrap pkg else pkg;

in
{
  config = mkIf (config.programs.homenix.enable && cfg.enable) {

    home.file = mkIf (!config.programs.homenix.isNixOS) {
      ".local/share/wayland-sessions/hyprland-uwsm.desktop".text = ''
        [Desktop Entry]
        Name=Hyprland (UWSM)
        Comment=Hyprland Wayland Compositor with UWSM Session Management
        Exec=uwsm start ${nixGLWrapIfReq pkgs.hyprland}/bin/start-hyprland
        Type=Application
        DesktopNames=Hyprland
      '';
    };

    home.activation.hyprland-desktop-warning = mkIf (!config.programs.homenix.isNixOS) (
      lib.hm.dag.entryAfter [ "setupHomenixConfigFolder" ] ''
        echo "========================================="
        echo "If you can't see the Hyprland (UWSM) entry in your display manager"
        echo "You might need to copy the desktop entry to the system path:"
        echo ""
        echo "sudo cp ~/.local/share/wayland-sessions/hyprland-uwsm.desktop /usr/share/wayland-sessions/"
        echo ""
        echo "========================================="
      ''
    );

    xdg.configFile = mkIf cfg.useUWSM {
      "uwsm/env".text = ''
        if [ -e "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh" ]; then
          . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
        fi

        export PATH="${config.home.profileDirectory}/bin:${config.home.homeDirectory}/.config/homenix/bin:$PATH"
        export XDG_DATA_DIRS="${config.home.profileDirectory}/share:$XDG_DATA_DIRS"
        export HOMENIX_PATH="${config.home.homeDirectory}/.config/homenix"
        export XDG_CURRENT_DESKTOP=Hyprland
        export XDG_SESSION_TYPE=wayland
        export GDK_BACKEND=wayland,x11
        export SDL_VIDEODRIVER=wayland
        export QT_QPA_PLATFORM="wayland;xcb"
        export QT_QPA_PLATFORMTHEME=gtk

        # Source user defaults
        if [ -f "${config.home.homeDirectory}/.config/uwsm/default" ]; then
            . "${config.home.homeDirectory}/.config/uwsm/default"
        fi
      '';

      "uwsm/default".text = ''
        export TERMINAL=xdg-terminal-exec

        ${cfg.uwsmEnvExtras}
      '';

      "uwsm/env-hyprland".text = ''
        # Hyprland-specific vars
      '';
    };
  };
}
