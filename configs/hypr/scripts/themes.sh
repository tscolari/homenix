#!/usr/bin/env bash

# ============================================================================
# Rofi Theme Switcher
# Lists theme directories and creates/updates a symlink to the selected theme
# ============================================================================


chosen_theme=$(echo "$($HOME/.config/homenix/bin/homenix-themes list)" | rofi -i -dmenu -window-title Themes)

# Main logic
if [[ -n "$chosen_theme" ]]; then
    # Theme selected - apply it.
    # Strip the list markers: "● " for the current theme, or the two-space
    # indent for the others. (NB: `local` is invalid outside a function.)
    theme_name="${chosen_theme#● }"
    theme_name="${theme_name#  }"
    $HOME/.config/homenix/bin/homenix-themes set "$theme_name"

    notify-send "Theme Switcher" "Switched to: $theme_name" -i preferences-desktop-theme 2>/dev/null
    $HOME/.config/hypr/scripts/refresh.sh
fi
