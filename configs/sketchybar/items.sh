#!/usr/bin/env bash
#
# All bar items. Right-side items are added in reverse visual order because the
# first item added to `right` sits furthest right (so clock ends up on the far
# right, exactly like waybar).

# ── Icon-only items ──────────────────────────────────────────────────────
# sketchybar keeps counting label.padding_* toward an item's width even when
# the label isn't drawn. With the 8/4/4/8 defaults an icon-only item therefore
# gets 8pt to the left of the glyph and 4+4+8=16pt to the right, leaving the
# glyph sitting 4pt left of the centre of its chip.
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
# Restart / Shut Down). Sourced first so the glyph is leftmost.
source "$CONFIG_DIR/apple.sh"

########################################################################
# CENTER — workspaces (optional)
########################################################################
# AeroSpace workspace indicator, see workspaces.sh. Off under OmniWM, whose
# built-in workspace bar owns the centre of the row instead.
if [ "$SKETCHYBAR_WORKSPACES" = on ]; then
  source "$CONFIG_DIR/workspaces.sh"
fi

########################################################################
# LEFT — focused window title
########################################################################
# Shows the focused window title (waybar hyprland/window), fetched from
# omniwmctl or aerospace, whichever is installed. Refreshed on app switch via the
# native front_app_switched event. AeroSpace also re-triggers that event from its
# on-focus-changed hook, so there the title tracks focus moves within an app too.
#
# On `left`, not `center`: the centre belongs to the workspace indicator, either
# workspaces.sh or OmniWM's own bar. OmniWM's bar is centre-anchored and cannot
# be moved off centre without it visibly sliding around — its width changes as
# workspaces and app icons come and go, and it grows about its own centre. See
# workspaceBar in modules/omniwm/settings.nix.
#
# OmniWM has no on-focus-changed hook, so a focus change between two windows of
# the same app will not refresh this until the next app switch. Closing that gap
# needs a long-running `omniwmctl watch focus --exec ...` agent.
sketchybar --add item front_app left \
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

# CPU — icon only, like waybar; click launches btop in ghostty.
sketchybar --add item cpu right \
  --set cpu \
    icon="$ICON_CPU" \
    icon.color="$TEAL" \
    "${ICON_ONLY[@]}" \
    click_script="open -na /Applications/Ghostty.app --args -e zsh -c 'btop'"

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
# invisible item whose only job is to re-scan.
#
# updates=on is required: a drawing=off item never runs its script under the
# default `when_shown`.
sketchybar --add item tray_watcher right \
  --set tray_watcher \
    drawing=off \
    updates=on \
    update_freq=15 \
    script="$PLUGIN_DIR/tray.sh"
