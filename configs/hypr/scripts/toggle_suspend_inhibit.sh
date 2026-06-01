#!/usr/bin/env bash
# Toggle systemd sleep inhibitor — prevents suspend while allowing screen lock to work normally.

LOCK_FILE="/tmp/hypr_suspend_inhibit.pid"

if [ -f "$LOCK_FILE" ]; then
    pid=$(cat "$LOCK_FILE")
    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid"
    fi
    rm -f "$LOCK_FILE"
    notify-send -e -u normal "Suspend inhibit" "Disabled — system will suspend normally"
else
    systemd-inhibit --what=sleep --who="Hyprland" --why="Manually suppressed" sleep infinity &
    echo $! > "$LOCK_FILE"
    notify-send -e -u low "Suspend inhibit" "Enabled — system will lock but not suspend"
fi
