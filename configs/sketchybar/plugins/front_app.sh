#!/usr/bin/env bash
#
# Focused window title (waybar hyprland/window), asked from whichever window
# manager is installed: omniwmctl (OmniWM) or aerospace (AeroSpace). Amethyst
# has no CLI, so without either one the title comes from System Events, which
# needs the Accessibility grant plugins/tray.sh already relies on. Falls back to
# the app name from the native event's $INFO when nothing answers.
#
# Runs on the native front_app_switched event, which AeroSpace also re-triggers
# from its on-focus-changed hook. OmniWM and Amethyst have no such hook, so
# there a focus move between two windows of the *same* app will not refresh the
# title until the next app switch. OmniWM needs [general] ipcEnabled = true,
# which modules/omniwm/settings.nix forces on.

app=""
title=""

if command -v omniwmctl >/dev/null 2>&1; then
  # One IPC round-trip, parsed twice — the title can contain tabs and newlines,
  # so it is not safe to pack both fields into a single delimited line.
  focused="$(omniwmctl query windows --focused --json 2>/dev/null)"
  app="$(printf '%s' "$focused" | jq -r '.result.payload.windows[0].app.name // ""' 2>/dev/null)"
  title="$(printf '%s' "$focused" | jq -r '.result.payload.windows[0].title // ""' 2>/dev/null)"
elif command -v aerospace >/dev/null 2>&1; then
  app="$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)"
  title="$(aerospace list-windows --focused --format '%{window-title}' 2>/dev/null)"
elif [ -x /usr/bin/osascript ]; then
  # timeout: System Events can hang while an app is still launching, which
  # would stall every later front_app_switched update.
  title="$(timeout 2 /usr/bin/osascript -e 'tell application "System Events" to get name of first window of (first application process whose frontmost is true)' 2>/dev/null)"
fi

# Fall back to the app name, then to the native event's $INFO, when the focused
# window has no title (or nothing is focused at all).
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
