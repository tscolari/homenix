#!/usr/bin/env bash
#
# Center item: focused window title (waybar hyprland/window) — OmniWM variant of
# ../../sketchybar/plugins/front_app.sh, which asks `aerospace` instead.
#
# Runs on the native front_app_switched event. Note OmniWM has no
# on-focus-changed hook to re-trigger that event, so moving focus between two
# windows of the *same* app will not refresh the title until the next app
# switch. Requires [general] ipcEnabled = true, which modules/omniwm/settings.nix
# forces on.

# One IPC round-trip, parsed twice — the title can contain tabs and newlines, so
# it is not safe to pack both fields into a single delimited line.
focused="$(omniwmctl query windows --focused --json 2>/dev/null)"
app="$(printf '%s' "$focused" | jq -r '.result.payload.windows[0].app.name // ""' 2>/dev/null)"
title="$(printf '%s' "$focused" | jq -r '.result.payload.windows[0].title // ""' 2>/dev/null)"

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
