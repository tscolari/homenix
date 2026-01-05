{
  lib,
  config,
  ...
}:

with lib;

let
  # Only enable this on non-NixOS systems
  isNonNixOS = !config.programs.homenix.isNixOS or true;

  # System paths that need to be included
  systemDataDirs = [
    "/usr/share"
    "/usr/local/share"
    "/var/lib/flatpak/exports/share"
    "$HOME/.local/share/flatpak/exports/share"
  ];

  # GSettings schema paths - critical for GTK apps
  systemSchemaDirs = [
    "/usr/share/glib-2.0/schemas"
    "/usr/local/share/glib-2.0/schemas"
  ];

in
{
  config = mkIf (config.programs.homenix.enable && isNonNixOS) {
    home.sessionVariables = {
      # Ensure system XDG data dirs are included (for portals, icons, themes, etc.)
      XDG_DATA_DIRS = mkForce (
        lib.concatStringsSep ":" (
          [
            "$HOME/.nix-profile/share"
            "/nix/var/nix/profiles/default/share"
            "${config.home.profileDirectory}/share"
          ]
          ++ systemDataDirs
          ++ [
            "$XDG_DATA_DIRS"
          ]
        )
      );

      # GSettings schemas - GTK apps need this to find their settings
      GSETTINGS_SCHEMA_DIR = lib.concatStringsSep ":" (
        [
          "$HOME/.nix-profile/share/glib-2.0/schemas"
          "${config.home.profileDirectory}/share/glib-2.0/schemas"
        ]
        ++ systemSchemaDirs
      );

      # GI typelib path for introspection (needed by some GTK apps)
      # System paths MUST come first to prevent conflicts with system GTK apps
      GI_TYPELIB_PATH = lib.concatStringsSep ":" [
        "/usr/lib/x86_64-linux-gnu/girepository-1.0"
        "/usr/lib/girepository-1.0"
        "$HOME/.nix-profile/lib/girepository-1.0"
        "${config.home.profileDirectory}/lib/girepository-1.0"
      ];
    };

    # For UWSM, also add these to the env file
    xdg.configFile."uwsm/env-nonixos".text = mkIf config.programs.homenix.hyprland.useUWSM ''
      # Non-NixOS XDG Portal and Schema compatibility
      export XDG_DATA_DIRS="${config.home.profileDirectory}/share:$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share:/usr/share:/usr/local/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"

      export GSETTINGS_SCHEMA_DIR="${config.home.profileDirectory}/share/glib-2.0/schemas:$HOME/.nix-profile/share/glib-2.0/schemas:/usr/share/glib-2.0/schemas:/usr/local/share/glib-2.0/schemas"

      export GI_TYPELIB_PATH="/usr/lib/x86_64-linux-gnu/girepository-1.0:/usr/lib/girepository-1.0:${config.home.profileDirectory}/lib/girepository-1.0:$HOME/.nix-profile/lib/girepository-1.0"
    '';
  };
}
