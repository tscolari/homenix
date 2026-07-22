#!/usr/bin/env bash
#
# Center item: focused window title (waybar hyprland/window).
#
# Fetched from aerospace so it tracks window focus, not just app switches. Runs
# on front_app_switched (native app change) and whenever aerospace's
# on-focus-changed re-triggers front_app_switched. Falls back to the app name
# when a window has no title, and applies the same rewrites as the waybar config.

title="$(aerospace list-windows --focused --format '%{window-title}' 2>/dev/null)"
app="$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)"

# Fall back to app name (or the native event's $INFO) when there's no title.
[ -z "$title" ] && title="${app:-$INFO}"

# waybar rewrites: "<page> — Mozilla Firefox" -> "<page>"
case "$title" in
  *" — Mozilla Firefox") title="${title% — Mozilla Firefox}" ;;
esac

# waybar max-length = 120
if [ "${#title}" -gt 120 ]; then
  title="${title:0:117}..."
fi

sketchybar --set "$NAME" label="${title:-$app}"
