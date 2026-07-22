#!/usr/bin/env bash
#
# Weather module — wttr.in, mirroring the waybar custom/weather script.
# Location: $SKETCHYBAR_WEATHER_LOCATION, else London. Leave the location empty
# ("") to let wttr.in geolocate by IP.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

location="${SKETCHYBAR_WEATHER_LOCATION-London}"

# %C = condition text, %t = temperature.
weather="$(curl -s --max-time 5 "https://wttr.in/${location}?format=%C+%t" 2>/dev/null | tr -s ' ')"

if [ -n "$weather" ] && ! printf '%s' "$weather" | grep -qi 'unknown\|error'; then
  sketchybar --set "$NAME" icon="$ICON_WEATHER" icon.color="$RED" label="$weather"
else
  sketchybar --set "$NAME" icon="$ICON_WEATHER" icon.color="$RED" label="—"
fi
