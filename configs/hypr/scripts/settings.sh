#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Rofi menu for KooL Hyprland Quick Settings (SUPER SHIFT E)

tmp_config_file=$(mktemp)
sed 's/^\$//g; s/ = /=/g' "$config_file" > "$tmp_config_file"
source "$tmp_config_file"
# ##################################### #

# variables
scriptsDir="$HOME/.config/hypr/scripts"

# Function to display the menu options without numbers
menu() {
    cat <<EOF
Refresh Bar and Menus
Configure Monitors (nwg-displays)
Choose Monitor Profiles
Wallpapers
Animations
Power Profiles
Hyprsunset
Change Theme
Toggle Master/Dwindle Layout
Toggle Game Mode
GTK Settings (nwg-look)
QT Apps Settings (qt6ct)
QT Apps Settings (qt5ct)
Search for Keybinds
EOF
}

# Main function to handle menu selection
main() {
    choice=$(menu | rofi -i -dmenu -window-title "Settings")

    # Map choices to corresponding files
    case "$choice" in
        "Refresh Bar and Menus")
            $scriptsDir/refresh.sh
            ;;
        "Configure Monitors (nwg-displays)")
            if ! command -v nwg-displays &>/dev/null; then
                notify-send -i "$iDIR/error.png" "E-R-R-O-R" "Install nwg-displays first"
                exit 1
            fi
            nwg-displays
            ;;
        "GTK Settings (nwg-look)")
            if ! command -v nwg-look &>/dev/null; then
                notify-send -i "$iDIR/error.png" "E-R-R-O-R" "Install nwg-look first"
                exit 1
            fi
            nwg-look ;;
        "QT Apps Settings (qt6ct)")
            if ! command -v qt6ct &>/dev/null; then
                notify-send -i "$iDIR/error.png" "E-R-R-O-R" "Install qt6ct first"
                exit 1
            fi
            qt6ct ;;
        "QT Apps Settings (qt5ct)")
            if ! command -v qt5ct &>/dev/null; then
                notify-send -i "$iDIR/error.png" "E-R-R-O-R" "Install qt5ct first"
                exit 1
            fi
            qt5ct ;;
        "Wallpapers")
            $scriptsDir/wallpaper.sh
            ;;
        "Animations")
            $scriptsDir/animations.sh
            ;;
        "Power Profiles")
            $scriptsDir/power_profiles.sh
            ;;
        "Hyprsunset")
            $scriptsDir/hyprsunset.sh toggle
            ;;
        "Toggle Master/Dwindle Layout")
            $scriptsDir/change_layout.sh
            ;;
        "Toggle Game Mode")
            $scriptsDir/game_mode.sh
            ;;
        "Change Theme")
            $scriptsDir/themes.sh
            ;;
        "Choose Monitor Profiles") $scriptsDir/monitor_profiles.sh ;;
        "Search for Keybinds") $scriptsDir/keybinds.sh ;;
        *) return ;;  # Do nothing for invalid choices
    esac

    # Open the selected file in the terminal with the text editor
    if [ -n "$file" ]; then
        $term -e $edit "$file"
    fi
}

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

main
