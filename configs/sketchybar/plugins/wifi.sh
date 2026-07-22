#!/usr/bin/env bash
#
# Network module. Icon-only like waybar: wifi glyph when associated, ethernet
# glyph when there's a default route but no Wi-Fi, disconnected otherwise.
#
# NOTE: macOS 14+ hides the SSID from `airport -I`, so we read it from
# `ipconfig getsummary` and fall back to `networksetup`. Interface is assumed
# en0 — adjust if your Wi-Fi is on a different device.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

iface=en0

ssid="$(ipconfig getsummary "$iface" 2>/dev/null | awk -F 'SSID : ' '/ SSID : / {print $2; exit}')"
if [ -z "$ssid" ]; then
  ssid="$(networksetup -getairportnetwork "$iface" 2>/dev/null | sed 's/^Current Wi-Fi Network: //')"
  case "$ssid" in
    *"not associated"*|"You are not associated"*|"") ssid="" ;;
  esac
fi

if [ -n "$ssid" ]; then
  sketchybar --set "$NAME" icon="$ICON_WIFI" icon.color="$FG"
elif route -n get default >/dev/null 2>&1; then
  sketchybar --set "$NAME" icon="$ICON_ETHERNET" icon.color="$FG"
else
  sketchybar --set "$NAME" icon="$ICON_WIFI_OFF" icon.color="$SUBTEXT"
fi
