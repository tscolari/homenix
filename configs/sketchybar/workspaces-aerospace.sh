#!/usr/bin/env bash
#
# CENTER — AeroSpace workspace indicator. Sourced by items.sh when
# SKETCHYBAR_WORKSPACES=aerospace, which modules/sketchybar writes to options.sh
# from programs.homenix.sketchybar.workspaces. OmniWM turns the indicator off
# because it draws its own workspace bar in the same spot.
#
# Static items for workspaces 1..9 (matches the cmd-1..9 binds). Workspaces
# 1..$PERSISTENT_SPACES are always drawn (waybar's persistent-workspaces);
# above that they appear only while occupied, like waybar's
# hyprland/workspaces. plugins/aerospace.sh does the highlighting/hiding.
#
# updates=on is required, not cosmetic: with the default `when_shown` an item
# that the plugin hides with drawing=off stops running its script, so it can
# never decide to come back.

# Fired by AeroSpace's exec-on-workspace-change (modules/aerospace).
sketchybar --add event aerospace_workspace_change

PERSISTENT_SPACES=4

for sid in $(seq 1 9); do
  if [ "$sid" -le "$PERSISTENT_SPACES" ]; then persistent=on; else persistent=off; fi

  sketchybar --add item "space.$sid" center \
    --subscribe "space.$sid" aerospace_workspace_change \
    --set "space.$sid" \
      icon="$sid" \
      icon.color="$FG" \
      "${ICON_ONLY[@]}" \
      background.drawing=off \
      updates=on \
      click_script="aerospace workspace $sid" \
      script="$PLUGIN_DIR/aerospace.sh $sid $persistent"
done

# The space items only run on aerospace_workspace_change, so fire it once for
# the initial paint.
sketchybar --trigger aerospace_workspace_change \
  FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused 2>/dev/null)"
