#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Game Mode. Turning off all animations

notif="$HOME/.config/swaync/images/ja.png"
scripts_dir="$HOME/.config/hypr/scripts"
image_path=$HOME/.config/homenix/current/background


HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
if [ "$HYPRGAMEMODE" = 1 ] ; then
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:shadow:enabled 0;\
        keyword decoration:blur:enabled 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"

	hyprctl keyword "windowrule opacity 1 override 1 override 1 override, ^(.*)$"
    pkill swaybg 2>/dev/null
    notify-send -e -u low -i "$notif" " Gamemode:" " enabled"
    sleep 0.1
    exit
else
    setsid uwsm-app -- swaybg -i "$image_path" -m fill >/dev/null 2>&1 &
    sleep 0.1
    hyprctl reload
    ${scripts_dir}/refresh.sh
    notify-send -e -u normal -i "$notif" " Gamemode:" " disabled"
    exit
fi
hyprctl reloadToggle Game Mode
