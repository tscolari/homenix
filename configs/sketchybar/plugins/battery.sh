#!/usr/bin/env bash
#
# Battery module. Shows "<icon> <pct>%" (waybar showed "{capacity}% {icon}").
# Colours: warning <=20%, critical <=10% (waybar states warning=20 critical=10).

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

batt="$(pmset -g batt)"
pct="$(printf '%s' "$batt" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"
[ -z "$pct" ] && exit 0

if printf '%s' "$batt" | grep -q 'AC Power'; then
  icon="$ICON_BATTERY_CHARGING"; color="$GREEN"
else
  case "$pct" in
    100|9[0-9])            icon="$ICON_BATTERY_100" ;;
    8[0-9]|7[0-9])         icon="$ICON_BATTERY_75" ;;
    6[0-9]|5[0-9]|4[0-9])  icon="$ICON_BATTERY_50" ;;
    3[0-9]|2[0-9])         icon="$ICON_BATTERY_25" ;;
    *)                     icon="$ICON_BATTERY_10" ;;
  esac
  if [ "$pct" -le 10 ]; then
    color="$RED"
  elif [ "$pct" -le 20 ]; then
    color="$YELLOW"
  else
    color="$FG"
  fi
fi

sketchybar --set "$NAME" icon="$icon" icon.color="$color" label="${pct}%"
