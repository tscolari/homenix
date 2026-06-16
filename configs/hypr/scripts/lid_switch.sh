#!/usr/bin/env bash
# Laptop lid handling that won't crash Hyprland.
# Disabling the ONLY monitor makes Hyprland 0.55.x enter unsafe-state and SIGSEGV,
# so only disable the internal panel when an external monitor is connected;
# laptop-only we do nothing and let logind suspend. (Mirrors omarchy.)

# internal panel name from DRM sysfs (e.g. card1-eDP-1 -> eDP-1)
internal="eDP-1"
for s in /sys/class/drm/card*-eDP-*/status; do
  [ -e "$s" ] || continue
  d=$(basename "$(dirname "$s")")
  internal=${d#card*-}
  break
done

external_connected() {
  for s in /sys/class/drm/card*-*/status; do
    case "$s" in *-eDP-*) continue ;; esac
    [ "$(cat "$s" 2>/dev/null)" = "connected" ] && return 0
  done
  return 1
}

case "${1:-}" in
  close) external_connected && hyprctl keyword monitor "$internal,disable" ;;
  open) hyprctl keyword monitor "$internal,preferred,auto,1.5" ;;
  *)
    echo "usage: $(basename "$0") {open|close}" >&2
    exit 1
    ;;
esac
