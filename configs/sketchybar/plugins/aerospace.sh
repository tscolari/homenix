#!/usr/bin/env bash
#
# Workspace item renderer. Mirrors waybar's hyprland/workspaces:
#   - focused workspace is highlighted (blue icon on a chip)
#   - occupied-but-unfocused workspaces are shown plainly
#   - empty, unfocused workspaces are hidden
#
# $1                 this item's workspace id (baked into the item's script=)
# $FOCUSED_WORKSPACE set by the aerospace_workspace_change trigger; on the very
#                    first paint it's queried directly.

source "$CONFIG_DIR/colors.sh"

sid="$1"
focused="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

occupied=off
if [ -n "$(aerospace list-windows --workspace "$sid" 2>/dev/null)" ]; then
  occupied=on
fi

if [ "$sid" = "$focused" ]; then
  sketchybar --set "$NAME" \
    drawing=on \
    background.drawing=on \
    background.color="$ACTIVE_BG" \
    icon.color="$ACTIVE"
elif [ "$occupied" = on ]; then
  sketchybar --set "$NAME" \
    drawing=on \
    background.drawing=off \
    icon.color="$FG"
else
  sketchybar --set "$NAME" drawing=off
fi
