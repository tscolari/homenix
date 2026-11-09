#!/usr/bin/env bash
#
# CENTER — macOS Spaces (Mission Control desktops) workspace indicator, for
# window managers that sit on native Spaces and expose no workspace CLI
# (Amethyst). Sourced by items.sh when SKETCHYBAR_WORKSPACES=spaces.
#
# sketchybar's native `space` items track Mission Control directly: each one is
# bound to a desktop index, only drawn while that desktop exists, and receives
# space_change with $SELECTED. plugins/space.sh does the highlighting.
#
# Clicking sends Command+<n>, the "Switch to Desktop <n>" shortcut the Amethyst
# module assigns. That keystroke goes through System Events, so it needs the
# same Accessibility grant plugins/tray.sh already relies on.

# Mac virtual key codes for the digits 1..9 (they are not sequential).
SPACE_KEYCODES=(18 19 20 21 23 22 26 28 25)

for sid in $(seq 1 9); do
  keycode="${SPACE_KEYCODES[$((sid - 1))]}"

  sketchybar --add space "space.$sid" center \
    --set "space.$sid" \
      space="$sid" \
      icon="$sid" \
      icon.color="$FG" \
      "${ICON_ONLY[@]}" \
      background.drawing=off \
      script="$PLUGIN_DIR/space.sh" \
      click_script="osascript -e 'tell application \"System Events\" to key code $keycode using command down'"
done
