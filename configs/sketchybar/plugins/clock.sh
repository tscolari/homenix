#!/usr/bin/env bash
#
# Clock module.
#   - label: HH:MM:SS  <weekday> <day>   (waybar showed HH:MM:SS  %d, %A)
#   - click: opens Notification Center — the native macOS menu-bar-clock
#            behaviour, and where the swaync/group-notify functionality lands.
#
# The Notification Center click drives Control Center via System Events, which
# needs Accessibility permission for the sketchybar process
# (System Settings → Privacy & Security → Accessibility). It falls back to
# opening Calendar if that's not granted.

if [ "$1" = "open" ]; then
  osascript -e 'tell application "System Events" to tell process "ControlCenter" to click menu bar item "Clock" of menu bar 1' 2>/dev/null \
    || open -a "Calendar"
  exit 0
fi

sketchybar --set "$NAME" label="$(date '+%H:%M:%S  %a %d')"
