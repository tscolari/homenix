#!/usr/bin/env bash
#
# All bar items. Right-side items are added in reverse visual order because the
# first item added to `right` sits furthest right (so clock ends up on the far
# right, exactly like waybar).

# ── Icon-only items ──────────────────────────────────────────────────────
# sketchybar keeps counting label.padding_* toward an item's width even when
# the label isn't drawn. With the 8/4/4/8 defaults an icon-only item therefore
# gets 8pt to the left of the glyph and 4+4+8=16pt to the right, leaving the
# glyph sitting 4pt left of the centre of its chip — visible on the focused
# workspace, and on every icon-only status chip.
#
# Zeroing the label padding and splitting the same 24pt total evenly centres
# the glyph without changing the item's width, so nothing else on the bar
# shifts. Apply to any item that draws an icon and no label.
ICON_ONLY=(
  label.drawing=off
  label.padding_left=0
  label.padding_right=0
  icon.padding_left=12
  icon.padding_right=12
)

########################################################################
# LEFT — Apple power menu (leftmost, where the native Apple menu sits)
########################################################################
# In-bar replacement for waybar's custom/power (Lock / Sleep / Log Out /
# Restart / Shut Down). Sourced before the workspaces so the glyph is leftmost.
source "$CONFIG_DIR/apple.sh"

########################################################################
# LEFT — AeroSpace workspaces
########################################################################
# Static items for workspaces 1..9 (matches the cmd-1..9 binds). Workspaces
# 1..$PERSISTENT_SPACES are always drawn (waybar's persistent-workspaces);
# above that they appear only while occupied, like waybar's
# hyprland/workspaces. The plugin does the highlighting/hiding.
#
# updates=on is required, not cosmetic: with the default `when_shown` an item
# that the plugin hides with drawing=off stops running its script, so it can
# never decide to come back — which is why only one workspace ever showed.
PERSISTENT_SPACES=4

for sid in $(seq 1 9); do
  if [ "$sid" -le "$PERSISTENT_SPACES" ]; then persistent=on; else persistent=off; fi

  sketchybar --add item "space.$sid" left \
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

########################################################################
# CENTER — focused window title
########################################################################
# Shows the focused window title (waybar hyprland/window), fetched from
# aerospace. Refreshed on app switch (front_app_switched) and on any aerospace
# focus change (on-focus-changed in aerospace re-triggers front_app_switched).
sketchybar --add item front_app center \
  --set front_app \
    icon.drawing=off \
    label.color="$MAUVE" \
    background.drawing=off \
    script="$PLUGIN_DIR/front_app.sh" \
  --subscribe front_app front_app_switched

########################################################################
# RIGHT — status modules (added right-to-left)
########################################################################

# Clock — clicking opens Notification Center (native macOS clock behaviour).
sketchybar --add item clock right \
  --set clock \
    icon="$ICON_CLOCK" \
    icon.color="$SAPPHIRE" \
    update_freq=1 \
    script="$PLUGIN_DIR/clock.sh" \
    click_script="$PLUGIN_DIR/clock.sh open"

# Weather — wttr.in; click opens Weather.app.
# Location: set SKETCHYBAR_WEATHER_LOCATION, else defaults to London.
sketchybar --add item weather right \
  --set weather \
    icon="$ICON_WEATHER" \
    icon.color="$RED" \
    update_freq=3600 \
    script="$PLUGIN_DIR/weather.sh" \
    click_script="open -a Weather"

# Battery — click opens Battery settings.
sketchybar --add item battery right \
  --set battery \
    update_freq=120 \
    script="$PLUGIN_DIR/battery.sh" \
    click_script="open 'x-apple.systempreferences:com.apple.Battery-Settings.extension'" \
  --subscribe battery power_source_change system_woke

# CPU — icon only, like waybar; click launches btop in ghostty (mirrors the
# waybar launch-or-focus-tui btop). Adjust the app path if yours differs, or
# swap in a launch-or-focus helper for focus-if-already-running behaviour.
# (Uncomment update_freq + script to show a live percentage instead.)
sketchybar --add item cpu right \
  --set cpu \
    icon="$ICON_CPU" \
    icon.color="$TEAL" \
    "${ICON_ONLY[@]}" \
    click_script="open -na /Applications/ghostty.app --args -e zsh -c 'btop'"
# To show a live percentage instead, re-add the label padding that ICON_ONLY
# zeroed, otherwise the text sits flush against the chip edge:
# --set cpu update_freq=5 script="$PLUGIN_DIR/cpu.sh" \
#   label.drawing=on icon.padding_left=8 icon.padding_right=4 \
#   label.padding_left=4 label.padding_right=8

# Volume — click opens Sound settings, right-click mutes, scroll adjusts.
sketchybar --add item volume right \
  --set volume \
    icon="$ICON_VOLUME" \
    icon.color="$LAVENDER" \
    "${ICON_ONLY[@]}" \
    script="$PLUGIN_DIR/volume.sh" \
    click_script="$PLUGIN_DIR/volume.sh click" \
  --subscribe volume volume_change mouse.scrolled

# Wi-Fi — click opens Wi-Fi settings.
sketchybar --add item wifi right \
  --set wifi \
    icon="$ICON_WIFI" \
    "${ICON_ONLY[@]}" \
    update_freq=5 \
    script="$PLUGIN_DIR/wifi.sh" \
    click_script="open 'x-apple.systempreferences:com.apple.wifi-settings-extension'"

# Bluetooth — click opens Bluetooth settings, right-click toggles power.
sketchybar --add item bluetooth right \
  --set bluetooth \
    icon="$ICON_BLUETOOTH" \
    "${ICON_ONLY[@]}" \
    update_freq=10 \
    script="$PLUGIN_DIR/bluetooth.sh" \
    click_script="$PLUGIN_DIR/bluetooth.sh click"

# Tray — waybar's `tray`, as close as macOS allows. The items themselves are
# created and destroyed by the plugin as apps come and go; this watcher is an
# invisible item whose only job is to re-scan. See plugins/tray.sh for why this
# can't use sketchybar's native aliases.
#
# updates=on is required: a drawing=off item never runs its script under the
# default `when_shown`.
sketchybar --add item tray_watcher right \
  --set tray_watcher \
    drawing=off \
    updates=on \
    update_freq=15 \
    script="$PLUGIN_DIR/tray.sh"

# The Apple power menu is sourced at the top (LEFT section). To fall back to the
# native Apple menu instead, remove that `source "$CONFIG_DIR/apple.sh"` line.
