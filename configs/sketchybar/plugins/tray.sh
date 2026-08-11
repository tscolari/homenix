#!/bin/sh
#
# Tray — the closest macOS equivalent of waybar's `tray` module.
#
# POSIX sh, deliberately: sketchybar parses plugin scripts with /bin/sh and
# ignores the shebang, so bashisms are fatal here even though the file is
# executable and starts with a bash shebang. A heredoc inside $(...), process
# substitution and arrays all fail to *parse*, which kills the whole script
# rather than the one line. Validate changes with `sh -n`, never `bash -n`.
#
# WHY NOT sketchybar's `alias`: sketchybar's built-in way to show menu bar
# extras is an alias item, which screenshots the real menu bar item and redraws
# it. That needs Screen Recording permission, which a configuration profile
# blocks on this machine, so `--query default_menu_items` fails and aliases can
# never render. (If you ever run somewhere Screen Recording *is* grantable,
# aliases give you the apps' real artwork and are the better option — see the
# note at the bottom of this file.)
#
# INSTEAD: enumerate the status menu items over Accessibility (System Events)
# and draw one Nerd Font glyph per owning app. Clicking a glyph clicks the real
# menu bar item, so the app's own native menu opens. The trade-off versus
# waybar is the icons are glyphs from the mapping below rather than each app's
# real artwork.
#
# REQUIRES: sketchybar must hold Accessibility permission (System Settings →
# Privacy & Security → Accessibility). Without it osascript fails with
# "not allowed assistive access (-1719)" in the launchd log and the tray stays
# empty. Note the grant is keyed to sketchybar's /nix/store path, so it has to
# be re-granted whenever the sketchybar package is bumped.
#
# Runs at startup and every update_freq seconds from the hidden `tray_watcher`
# item in items.sh, so extras from apps launched later appear too.

. "$CONFIG_DIR/colors.sh"

# Owners never worth drawing: Apple's own agents, plus anything this bar
# already has a dedicated item for (wifi/bluetooth/volume/battery/clock).
TRAY_IGNORE="Control Center|SystemUIServer|Spotlight|TextInputMenuAgent|Clock|WindowManager|Dock"

# Nerd Font glyph per app. Unknown apps fall back to a generic glyph — add a
# line here when a new tray app shows up.
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
  Tailscale | NordVPN | "Mullvad VPN") printf '󰖂' ;;
  Stats | iStat*) printf '󰄨' ;;
  *) printf '󰐱' ;;
  esac
}

# Item names are sanitised to [A-Za-z0-9_], so a space-delimited string is a
# safe stand-in for the set type POSIX sh doesn't have.
sanitise() { printf '%s' "$1" | sed 's/[^A-Za-z0-9]/_/g'; }
contains() { # set needle
  case " $1 " in
  *" $2 "*) return 0 ;;
  esac
  return 1
}

# ── Enumerate current status menu owners ─────────────────────────────────
# Status items live in `menu bar 2` of the owning process (menu bar 1 is the
# app's own menu bar), so the try-block silently skips everything else.
#
# The heredoc lives in a function because macOS's /bin/sh cannot parse one
# inside a command substitution.
scan_status_menus() {
  osascript <<'APPLESCRIPT'
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
}

# stderr is deliberately not suppressed: the per-process `try` swallows the
# processes that simply have no status menu, so anything that does come out is
# a real failure (usually the missing Accessibility grant) and belongs in the
# launchd log.
owners=$(scan_status_menus | grep -Ev "^($TRAY_IGNORE)$" | sort -u)

# No Accessibility (or System Events wedged) — leave the bar alone rather than
# tearing down a tray that may still be correct.
[ -n "$owners" ] || exit 0

# ── Diff against what's already on the bar ───────────────────────────────
existing=$(sketchybar --query bar 2>/dev/null |
  jq -r '.items[] | select(startswith("tray."))' | sort | tr '\n' ' ')
desired=$(printf '%s\n' "$owners" | sed 's/[^A-Za-z0-9]/_/g; s/^/tray./' |
  sort | tr '\n' ' ')

changed=off

# Remove tray items whose app has quit.
for item in $existing; do
  if ! contains "$desired" "$item"; then
    sketchybar --remove "$item"
    changed=on
  fi
done

# Add tray items for apps that appeared. The heredoc keeps this loop in the
# current shell so `changed` survives it.
while IFS= read -r owner; do
  [ -n "$owner" ] || continue
  item="tray.$(sanitise "$owner")"
  contains "$existing" "$item" && continue

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

[ "$changed" = on ] || exit 0

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
