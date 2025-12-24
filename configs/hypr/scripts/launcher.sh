pkill rofi || true
exec rofi -show drun -dump \
    -modi "drun,filebrowser,run,window" \
    -kb-mode-next "Ctrl+Tab" -kb-mode-previous "Ctrl+Shift+Tab"
