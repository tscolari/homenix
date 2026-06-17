#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# For applying Animations from different users

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Variables
iDIR="$HOME/.config/swaync/images"
scripts_dir="$HOME/.config/hypr/scripts"
animations_dir="$HOME/.config/hypr/animations"
current_animation_file=$HOME/.config/hypr/current_animation.lua

# list of animation files, sorted alphabetically with numbers first
animations_list=$(find -L "$animations_dir" -maxdepth 1 -type f | sed 's/.*\///' | sed 's/\.lua$//' | sort -V)

# Rofi Menu
chosen_file=$(echo "$animations_list" | rofi -i -dmenu -window-title Animation)

# Check if a file was selected
if [[ -n "$chosen_file" ]]; then
    full_path="$animations_dir/$chosen_file.lua"
    ln -sf "$full_path" $current_animation_file
    # Reload so the swapped current_animation.lua is re-read (refresh.sh alone
    # only restarts waybar/swaync/etc. and does not reload Hyprland's config).
    if command -v hyprctl >/dev/null 2>&1 && hyprctl instances >/dev/null 2>&1; then
        hyprctl reload >/dev/null 2>&1 || true
    fi
    notify-send -u low -i "$iDIR/ja.png" "$chosen_file" "Hyprland Animation Loaded"
fi

sleep 1
"$scripts_dir/refresh.sh"
