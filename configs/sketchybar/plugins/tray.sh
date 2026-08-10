#!/usr/bin/env bash
#
# Tray — the closest macOS equivalent of waybar's `tray` module.
#
# WHY NOT sketchybar's `alias`: sketchybar's built-in way to show menu bar
# extras is an alias item, which screenshots the real menu bar item and redraws
# it. That needs Screen Recording permission, which a configuration profile
# blocks on this machine, so `--query default_menu_items` fails and aliases can
# never render. (If you ever run somewhere Screen Recording *is* grantable,
# aliases give you the apps' real artwork and are the better option — see the
# note at the bottom of this file.)
#
# INSTEAD: enumerate the status menu items over Accessibility (System Events —
# the same permission AeroSpace already needs) and draw one Nerd Font glyph per
# owning app. Clicking a glyph clicks the real menu bar item, so the app's own
# native menu opens. The trade-off versus waybar is the icons are glyphs from
# the mapping below rather than each app's real artwork.
#
# Runs at startup and every update_freq seconds from the hidden `tray_watcher`
# item in items.sh, so extras from apps launched later appear too.

source "$CONFIG_DIR/colors.sh"

# Owners never worth drawing: Apple's own agents, plus anything this bar
# already has a dedicated item for (wifi/bluetooth/volume/battery/clock).
TRAY_IGNORE="Control Center|SystemUIServer|Spotlight|TextInputMenuAgent|Clock|WindowManager|Dock"

# Nerd Font glyph per app. Unknown apps fall back to a generic puzzle glyph —
# add a line here when a new tray app shows up.
tray_icon() {
  case "$1" in
  1Password | Bitwarden | KeePassXC) printf '󰌾' ;;
  "Okta Verify" | Authy) printf '󰒃' ;;
  Maccy | Paste) printf '󰅍' ;;
  LogiTune | "Logi Options+") printf '󰋋' ;;
  Notion | Obsidian) printf '󰠮' ;;
  AeroSpace | Rectangle | Amethyst) printf '󰕮' ;;
  Slack | Discord) printf '󰒱' ;;
  Docker | OrbStack) printf '󰡨' ;;
  Spotify) printf '󰓇' ;;
  zoom.us | "Microsoft Teams") printf '󰕧' ;;
  Tailscale | "NordVPN" | "Mullvad VPN") printf '󰖂' ;;
  Stats | iStat*) printf '󰄨' ;;
  *) printf '󰐱' ;;
  esac
}

# ── Enumerate current status menu owners ─────────────────────────────────
# Status items live in `menu bar 2` of the owning process (menu bar 1 is the
# app's own menu bar), so the try-block silently skips everything else.
# stderr is deliberately not suppressed: the per-process `try` swallows the
# processes that simply have no status menu, so anything that does come out is
# a real failure (usually "not allowed assistive access" — grant sketchybar
# Automation/Accessibility) and belongs in the launchd log.
raw=$(osascript <<'APPLESCRIPT'
tell application "System Events"
	set out to {}
	repeat with proc in every process
		try
			repeat with itm in menu bar items of menu bar 2 of proc
				set end of out to name of proc
			end repeat
		end try
	end repeat
	set AppleScript's text item delimiters to linefeed
	return out as text
end tell
APPLESCRIPT
)

owners=$(printf '%s\n' "$raw" | grep -Ev "^($TRAY_IGNORE)$" | sort -u)

# Accessibility not granted (or System Events wedged) — leave the bar alone
# rather than tearing down a tray that may still be correct.
[ -z "$owners" ] && exit 0

# ── Diff against what's already on the bar ───────────────────────────────
# Item names can't carry spaces, so "Okta Verify" becomes tray.Okta_Verify.
existing=$(sketchybar --query bar 2>/dev/null |
  jq -r '.items[] | select(startswith("tray."))' | sort)

desired=$(printf '%s\n' "$owners" | sed 's/[^A-Za-z0-9]/_/g; s/^/tray./' | sort)

changed=off

# Remove tray items whose app has quit.
for item in $(comm -23 <(printf '%s\n' "$existing") <(printf '%s\n' "$desired")); do
  sketchybar --remove "$item"
  changed=on
done

# Add tray items for apps that appeared.
while IFS= read -r owner; do
  [ -n "$owner" ] || continue
  item="tray.$(printf '%s' "$owner" | sed 's/[^A-Za-z0-9]/_/g')"
  printf '%s\n' "$existing" | grep -qx "$item" && continue

  # `click menu bar item 1` opens the app's own menu, exactly where the real
  # icon would have put it.
  sketchybar --add item "$item" right \
    --set "$item" \
      icon="$(tray_icon "$owner")" \
      icon.color="$FG" \
      label.drawing=off \
      label.padding_left=0 \
      label.padding_right=0 \
      background.drawing=off \
      icon.padding_left=4 \
      icon.padding_right=4 \
      padding_left=0 \
      padding_right=0 \
      click_script="osascript -e 'tell application \"System Events\" to tell process \"$owner\" to click menu bar item 1 of menu bar 2'"
  changed=on
done <<EOF
$owners
EOF

[ "$changed" = off ] && exit 0

# Anchor the tray just left of bluetooth — the leftmost of the right-hand
# modules, where waybar puts it. Without this each newly added item lands at
# whatever edge sketchybar picks and the group drifts apart as apps come and
# go. Done before the bracket so the bracket wraps them in place.
#
# `after bluetooth` reads backwards because the right region lays out
# right-to-left: later in the item list means further left on screen. Walking
# $desired in ascending order therefore renders the tray alphabetically
# left-to-right.
for item in $desired; do
  sketchybar --move "$item" after bluetooth
done

# ── Group the glyphs under one chip ──────────────────────────────────────
# waybar draws the whole tray as a single module, so the icons share one
# background instead of each getting its own. A bracket resolves its members
# when it's created, so it has to be rebuilt whenever membership changes.
sketchybar --remove tray_bracket 2>/dev/null
# shellcheck disable=SC2086 # deliberate word splitting: one argument per item
sketchybar --add bracket tray_bracket $desired \
  --set tray_bracket \
    background.color="$ITEM_BG" \
    background.corner_radius=6 \
    background.height=20

# ── If you ever get Screen Recording ─────────────────────────────────────
# Replace everything above with sketchybar's native aliases, which draw the
# apps' real icons:
#
#   sketchybar --query default_menu_items | jq -r '.[]' | while read -r entry; do
#     sketchybar --add alias "$entry" right \
#       --set "$entry" background.drawing=off icon.drawing=off label.drawing=off
#   done
#
# and set the native menu bar to auto-hide so the icons aren't drawn twice.
