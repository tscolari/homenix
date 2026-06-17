-- Autostart
-- https://wiki.hypr.land/Configuring/Basics/Autostart/

local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("wl-paste --type text --watch cliphist store -max-items 25")
    hl.exec_cmd("wl-paste --type image --watch cliphist store -max-items 25")
end)
