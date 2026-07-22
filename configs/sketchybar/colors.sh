#!/usr/bin/env bash
#
# Catppuccin Mocha fallbacks — mirrors the Hyprland fallback colour block and
# the per-module colours from the waybar CSS. A theme can override any of these
# by shipping ~/.config/homenix/current/theme/sketchybar.sh (sourced last), the
# same mechanism jankyborders uses.
#
# sketchybar colour format is 0xAARRGGBB (AA = alpha).

export BAR_COLOR=0x00000000  # transparent bar; chips carry the background
export ITEM_BG=0xff181825    # mantle — the waybar item chip background
export FG=0xffcdd6f4         # text / foreground
export SUBTEXT=0xffa6adc8    # muted (e.g. muted volume / disconnected)

# Accents, matched to the waybar per-module CSS colours.
export ACTIVE=0xff89b4fa     # active workspace icon (blue)
export ACTIVE_BG=0xff1e1e2e  # active workspace chip background
export BLUE=0xff89b4fa       # bluetooth on
export SAPPHIRE=0xff74c7ec   # clock
export TEAL=0xff94e2d5       # cpu
export MAUVE=0xffcba6f7      # focused app / window title
export RED=0xfff38ba8        # weather / urgent / power
export LAVENDER=0xffb4befe   # volume
export GREEN=0xffa6e3a1      # battery charging
export YELLOW=0xfff9e2af     # battery warning
export URGENT=0xfff38ba8

# ── Theme override (optional) ─────────────────────────────────────────────
theme_file="$HOME/.config/homenix/current/theme/sketchybar.sh"
[ -r "$theme_file" ] && source "$theme_file"
