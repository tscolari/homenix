#!/usr/bin/env bash
#
# Volume module. Mirrors waybar's pulseaudio:
#   - draws an icon that reflects the current level (volume_change event)
#   - left click  → Sound settings   (native "click volume" default)
#   - right click → toggle mute       (waybar on-click-right)
#   - scroll      → adjust volume ±5  (waybar scroll-step = 5)

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

render() {
  local vol="$1" icon color="$LAVENDER"
  if [ "$vol" -eq 0 ]; then
    icon="$ICON_VOLUME_MUTE"; color="$SUBTEXT"
  elif [ "$vol" -lt 34 ]; then
    icon="$ICON_VOLUME_1"
  elif [ "$vol" -lt 67 ]; then
    icon="$ICON_VOLUME_2"
  else
    icon="$ICON_VOLUME"
  fi
  sketchybar --set "$NAME" icon="$icon" icon.color="$color"
}

case "$SENDER" in
  volume_change)
    render "$INFO"
    ;;
  mouse.scrolled)
    delta="${SCROLL_DELTA%.*}"
    cur="$(osascript -e 'output volume of (get volume settings)')"
    if [ "${delta:-0}" -gt 0 ]; then new=$((cur + 5)); else new=$((cur - 5)); fi
    [ "$new" -lt 0 ] && new=0
    [ "$new" -gt 100 ] && new=100
    osascript -e "set volume output volume $new"
    ;;
  *)
    # Invoked via click_script with arg "click".
    if [ "$1" = "click" ]; then
      if [ "$BUTTON" = "right" ]; then
        osascript -e 'set volume output muted (not (output muted of (get volume settings)))'
      else
        open "x-apple.systempreferences:com.apple.Sound-Settings.extension"
      fi
    fi
    ;;
esac
