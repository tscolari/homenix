#!/usr/bin/env bash

# ============================================================================
# Rofi Theme Switcher
# Lists theme directories and creates/updates a symlink to the selected theme
# ============================================================================

# Configuration - adjust these paths as needed
THEMES_DIR="$HOME/.config/homenix/themes"
CURRENT_THEME_PATH="$HOME/.config/homenix/current/theme"

# ============================================================================

# Get the currently linked theme (if any)
get_current_theme() {
    if [[ -L "$CURRENT_THEME_PATH" ]]; then
        readlink -f "$CURRENT_THEME_PATH" | xargs basename
    else
        echo ""
    fi
}

# List all theme directories
list_themes() {
    local current_theme
    current_theme=$(get_current_theme)

    for dir in "$THEMES_DIR"/*/; do
        [[ -d "$dir" ]] || continue
        local theme_name
        theme_name=$(basename "$dir")

        if [[ "$theme_name" == "$current_theme" ]]; then
            echo "● $theme_name"
        else
            echo "  $theme_name"
        fi
    done
}

# Apply the selected theme
apply_theme() {
    local selection="$1"
    # Strip the marker prefix if present
    local theme_name="${selection#● }"
    theme_name="${theme_name#  }"

    local theme_path="$THEMES_DIR/$theme_name"

    if [[ -d "$theme_path" ]]; then
        # Remove existing symlink or file
        rm -f "$CURRENT_THEME_PATH"

        # Create new symlink
        ln -s "$theme_path" "$CURRENT_THEME_PATH"

        notify-send "Theme Switcher" "Switched to: $theme_name" -i preferences-desktop-theme 2>/dev/null
    fi
}

chosen_theme=$(echo "$(list_themes)" | rofi -i -dmenu -window-title Themes)

# Main logic
if [[ -n "$chosen_theme" ]]; then
    # Theme selected - apply it
    apply_theme "$chosen_theme"
fi
