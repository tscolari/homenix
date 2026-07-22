#!/usr/bin/env bash
#
# Bluetooth module.
#   - draws on/off state (via blueutil; falls back to a static icon)
#   - left click  → Bluetooth settings
#   - right click → toggle Bluetooth power (blueutil)

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# Click dispatch (click_script calls this with arg "click").
if [ "$1" = "click" ]; then
  if [ "$BUTTON" = "right" ] && command -v blueutil >/dev/null 2>&1; then
    state="$(blueutil -p)"
    blueutil -p "$((1 - state))"
  else
    open "x-apple.systempreferences:com.apple.BluetoothSettings"
  fi
  exit 0
fi

# Draw.
if command -v blueutil >/dev/null 2>&1; then
  if [ "$(blueutil -p)" = "1" ]; then
    sketchybar --set "$NAME" icon="$ICON_BLUETOOTH" icon.color="$BLUE"
  else
    sketchybar --set "$NAME" icon="$ICON_BLUETOOTH_OFF" icon.color="$SUBTEXT"
  fi
else
  sketchybar --set "$NAME" icon="$ICON_BLUETOOTH" icon.color="$FG"
fi
