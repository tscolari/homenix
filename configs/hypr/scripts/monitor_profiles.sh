#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# For applying Pre-configured Monitor Profiles

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Variables
scripts_dir="$HOME/.config/hypr/scripts"
monitor_dir="$HOME/.config/hypr/monitors"
monitors_target="$HOME/.config/hypr/monitors.conf"
workspaces_target="$HOME/.config/hypr/workspaces.conf"

# Define the list of files to ignore
ignore_files=(
  "README"
)

# list of Monitor Profiles, sorted alphabetically with numbers first
mon_profiles_list=$(find -L "$monitor_dir" -maxdepth 1 -type f | sed 's/.*\///' | sed 's/\.conf$//' | sort -V)

# Remove ignored files from the list
for ignored_file in "${ignore_files[@]}"; do
    mon_profiles_list=$(echo "$mon_profiles_list" | grep -v -E "^$ignored_file$")
done

# Rofi Menu
chosen_file=$(echo "$mon_profiles_list" | rofi -i -dmenu -window-title "Profile")

if [[ -n "$chosen_file" ]]; then
    monitors_path="$monitor_dir/$chosen_file.conf"
    workspaces_path="$monitor_dir/workspaces/$chosen_file.conf"
    cp "$monitors_path" "$monitors_target"
    cp "$workspaces_path" "$workspaces_target"

    sleep 1
    ${scripts_dir}/refresh.sh &
    notify-send -u low -i "$iDIR/ja.png" "$chosen_file" "Monitor Profile Loaded" 
fi

