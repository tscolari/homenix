#!/usr/bin/env bash

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

notif="$HOME/.config/swaync/images/ja.png"

# Get the list of available power profiles
profiles_output=$(powerprofilesctl list)

# Extract profile names and mark the active one
profiles=$(echo "$profiles_output" | grep -E '^\*?\s+[a-z-]+:' | sed 's/^[* ]*//;s/:$//')

# Get current active profile
current_profile=$(echo "$profiles_output" | grep '^\*' | sed 's/^[* ]*//;s/:$//')

# Create rofi menu with indicator for current profile
menu=""
while IFS= read -r profile; do
  if [ "$profile" = "$current_profile" ]; then
    menu+="󰸞 $profile (active)\n"
  else
    menu+="󱐋 $profile\n"
  fi
done <<< "$profiles"

# Show rofi menu
chosen=$(echo -e "$menu" | rofi -i -dmenu -window-title "Power Profile" -p "Select Profile")

if [[ -n "$chosen" ]]; then
  # Extract profile name (remove icon and "(active)" suffix)
  profile_name=$(echo "$chosen" | sed 's/^[󰸞󱐋] //;s/ (active)$//')

  # Set the selected power profile
  powerprofilesctl set "$profile_name"

  # Send notification
  notify-send -u low -i "$notif" "󱐋 Power Profile" "Switched to: $profile_name"
fi
