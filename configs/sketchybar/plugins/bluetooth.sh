#!/usr/bin/env bash
#
# Bluetooth module.
#   - draws on/off state (via blueutil; falls back to a static icon)
#   - left click  → Bluetooth settings
#   - right click → toggle Bluetooth power (blueutil)
#
# blueutil can block forever: when bluetoothd is wedged or the controller is
# off, IOBluetooth waits on a CoreBluetooth reply that never arrives. Each hung
# process holds a WindowServer connection it never drains, and a pile of them
# (one per update_freq tick) stalls input delivery to every app. bluetoothd
# also aborts itself with an XPC watchdog when callers sit on it, which makes
# things worse. Every call is therefore bounded by `timeout`, shorter than
# update_freq so at most one blueutil is ever alive.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

bt() { timeout 2 blueutil "$@"; }

# Click dispatch (click_script calls this with arg "click").
if [ "$1" = "click" ]; then
  if [ "$BUTTON" = "right" ] && command -v blueutil >/dev/null 2>&1; then
    state="$(bt -p)" || exit 0
    bt -p "$((1 - state))"
  else
    open "x-apple.systempreferences:com.apple.BluetoothSettings"
  fi
  exit 0
fi

# Draw.
if command -v blueutil >/dev/null 2>&1; then
  if [ "$(bt -p)" = "1" ]; then
    sketchybar --set "$NAME" icon="$ICON_BLUETOOTH" icon.color="$BLUE"
  else
    sketchybar --set "$NAME" icon="$ICON_BLUETOOTH_OFF" icon.color="$SUBTEXT"
  fi
else
  sketchybar --set "$NAME" icon="$ICON_BLUETOOTH" icon.color="$FG"
fi
