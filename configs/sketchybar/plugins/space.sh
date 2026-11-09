#!/usr/bin/env bash
#
# macOS Spaces item renderer (workspaces-spaces.sh). Highlights the focused
# desktop the same way plugins/aerospace.sh does for AeroSpace workspaces.
#
# $SELECTED  "true" on the space item of the focused desktop, set by sketchybar
#            on every space_change.

source "$CONFIG_DIR/colors.sh"

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color="$ACTIVE_BG" \
    icon.color="$ACTIVE"
else
  sketchybar --set "$NAME" \
    background.drawing=off \
    icon.color="$FG"
fi
