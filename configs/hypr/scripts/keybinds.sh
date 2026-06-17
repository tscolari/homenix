#!/usr/bin/env bash
# Searchable keybindings using hyprctl binds (Lua-config compatible)

pkill yad || true

if pidof rofi > /dev/null; then
  pkill rofi
fi

display_keybinds=$(hyprctl binds -j 2>/dev/null | jq -r '
  .[] |
  select(.submap == "") |
  [
    (if .modmask == 0 then "" else
      ([ if . and 1   > 0 then "SHIFT"   else empty end,
         if . and 4   > 0 then "CTRL"    else empty end,
         if . and 64  > 0 then "ALT"     else empty end,
         if . and 128 > 0 then "SUPER"   else empty end
       ] | join("+"))
     end) as $mods |
    (if $mods != "" then $mods + "+" else "" end) + .key,
    (if .description != "" then .description else .dispatcher + (if .arg != "" then " " + .arg else "" end) end)
  ] | join(" — ")
' 2>/dev/null)

if [[ -z "$display_keybinds" ]]; then
    notify-send "Keybinds" "hyprctl not available or no binds found"
    exit 1
fi

printf '%s\n' "$display_keybinds" | rofi -dmenu -i -window-title "Keybindings"
