#!/usr/bin/env bash
#
# OPTIONAL in-bar Apple power menu (popup). Source this from items.sh to enable.
# This is the in-bar replacement for waybar's custom/power. If you'd rather use
# the *native* Apple menu (top-left of the menu bar), just don't source this.

sketchybar --add item apple left \
  --set apple \
    icon="$ICON_APPLE" \
    icon.color="$FG" \
    background.drawing=off \
    popup.background.color="$ITEM_BG" \
    popup.background.corner_radius=8 \
    popup.background.border_color="$ACTIVE" \
    popup.background.border_width=2 \
    click_script="sketchybar --set apple popup.drawing=toggle"

apple_entry() { # name  icon  label  command
  sketchybar --add item "apple.$1" popup.apple \
    --set "apple.$1" \
      icon="$2" \
      label="$3" \
      background.drawing=off \
      click_script="sketchybar --set apple popup.drawing=off; $4"
}

apple_entry lock    "$ICON_LOCK"    "Lock Screen" "osascript -e 'tell application \"System Events\" to keystroke \"q\" using {control down, command down}'"
apple_entry sleep   "$ICON_SLEEP"   "Sleep"       "pmset sleepnow"
apple_entry logout  "$ICON_LOGOUT"  "Log Out"     "osascript -e 'tell application \"System Events\" to log out'"
apple_entry restart "$ICON_RESTART" "Restart"     "osascript -e 'tell application \"System Events\" to restart'"
apple_entry shut    "$ICON_POWER"   "Shut Down"   "osascript -e 'tell application \"System Events\" to shut down'"
