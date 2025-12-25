{
  lib,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.hyprland;

in
{
  config = mkIf (config.programs.homenix.enable && cfg.enable) {
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
        export QT_QPA_PLATFORMTHEME=qt6ct

        # Source user defaults
        if [ -f "${config.home.homeDirectory}/.config/uwsm/default" ]; then
            source "${config.home.homeDirectory}/.config/uwsm/default"
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
