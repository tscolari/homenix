-- Keybindings
-- https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod    = "SUPER"
local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"

-- ────────────────────────────────────────────────────────────────
-- System / session
-- ────────────────────────────────────────────────────────────────

hl.bind("CTRL + ALT + Delete", hl.dsp.exit(),                                                        { description = "exit Hyprland" })
hl.bind(mainMod .. " + Q",     hl.dsp.window.close(),                                                { description = "close active window" })
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/kill_focus.sh"), { description = "terminate active process" })
hl.bind("CTRL + ALT + L",      hl.dsp.exec_cmd("uwsm-app -- loginctl lock-session"),                 { description = "lock screen" })
hl.bind("CTRL + ALT + P",      hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/power_menu.sh"),    { description = "powermenu" })
hl.bind("CTRL + ALT + S",      hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/toggle_suspend_inhibit.sh"), { description = "toggle suspend inhibit" })
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("uwsm-app -- swaync-client -t -sw"),             { description = "notification panel" })
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/settings.sh"), { description = "quick settings menu" })

-- ────────────────────────────────────────────────────────────────
-- Layout: Master
-- ────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + CTRL + D", hl.dsp.layout("removemaster"),  { description = "remove master" })
hl.bind(mainMod .. " + I",        hl.dsp.layout("addmaster"),     { description = "add master" })
-- J/K bindings set dynamically by scripts/KeybindsLayoutInit.sh and scripts/ChangeLayout.sh

-- ────────────────────────────────────────────────────────────────
-- Layout: Dwindle
-- ────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + SHIFT + I", hl.dsp.layout("togglesplit"), { description = "toggle split (dwindle)" })
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo(),       { description = "toggle pseudo (dwindle)" })

-- ────────────────────────────────────────────────────────────────
-- Groups
-- ────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + ALT + G", hl.dsp.group.toggle(),  { description = "toggle group" })
hl.bind(mainMod .. " + CTRL + tab", hl.dsp.group.next(), { description = "change active in group" })

-- ────────────────────────────────────────────────────────────────
-- Special / media keys
-- ────────────────────────────────────────────────────────────────

hl.bind("xf86audioraisevolume", hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/volume.sh --inc"),         { repeating = true, locked = true, description = "volume up" })
hl.bind("xf86audiolowervolume", hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/volume.sh --dec"),         { repeating = true, locked = true, description = "volume down" })
hl.bind("xf86AudioMicMute",     hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/volume.sh --toggle-mic"), { locked = true, description = "toggle mic mute" })
hl.bind("xf86audiomute",        hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/volume.sh --toggle"),     { locked = true, description = "toggle mute" })
hl.bind("xf86Sleep",            hl.dsp.exec_cmd("systemctl suspend"),                                        { locked = true, description = "sleep" })
hl.bind("xf86Rfkill",           hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/airplane_mode.sh"),       { locked = true, description = "airplane mode" })

-- Media controls
-- NOTE: there is no XF86AudioPlayPause keysym; the play/pause toggle key
-- emits XF86AudioPlay, which is bound below to the play/pause action.
hl.bind("xf86audiopause",     hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/media_control.sh --pause"), { locked = true, description = "pause" })
hl.bind("xf86audioplay",      hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/media_control.sh --pause"), { locked = true, description = "play/pause" })
hl.bind("xf86audionext",      hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/media_control.sh --nxt"),   { locked = true, description = "next track" })
hl.bind("xf86audioprev",      hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/media_control.sh --prv"),   { locked = true, description = "previous track" })
hl.bind("xf86audiostop",      hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/media_control.sh --stop"),  { locked = true, description = "stop" })

-- ────────────────────────────────────────────────────────────────
-- Screenshots
-- ────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + Print",             hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/screenshot.sh --now"),   { description = "screenshot now" })
hl.bind(mainMod .. " + SHIFT + Print",     hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/screenshot.sh --area"),  { description = "screenshot (area)" })
hl.bind(mainMod .. " + CTRL + Print",      hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/screenshot.sh --in5"),   { description = "screenshot in 5s" })
hl.bind(mainMod .. " + CTRL + SHIFT + Print", hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/screenshot.sh --in10"), { description = "screenshot in 10s" })
hl.bind("ALT + Print",                     hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/screenshot.sh --active"), { description = "screenshot active window" })
hl.bind(mainMod .. " + SHIFT + S",         hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/screenshot.sh --area"),  { description = "screenshot (area)" })

-- ────────────────────────────────────────────────────────────────
-- Resize windows
-- ────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -50, y = 0,   relative = true }), { repeating = true, description = "resize left (-50)" })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 50,  y = 0,   relative = true }), { repeating = true, description = "resize right (+50)" })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0,   y = -50, relative = true }), { repeating = true, description = "resize up (-50)" })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }), { repeating = true, description = "resize down (+50)" })

-- ────────────────────────────────────────────────────────────────
-- Workspace navigation
-- ────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + tab",         hl.dsp.focus({ workspace = "m+1" }), { description = "next workspace" })
hl.bind(mainMod .. " + SHIFT + tab", hl.dsp.focus({ workspace = "m-1" }), { description = "previous workspace" })

-- hyprexpo plugin: workspace overview (SUPER + grave).
-- hyprexpo registers a lua plugin function (hl.plugin.hyprexpo.expo) via
-- addLuaFunction, so we bind a lua function that calls it. The closure defers the
-- hl.plugin.hyprexpo lookup to keypress time — by then the plugin has loaded and
-- registered the function (it does not exist at config-parse time).
hl.bind(mainMod .. " + grave", function() hl.plugin.hyprexpo.expo("toggle") end, { description = "toggle workspace overview" })

-- Switch / move / move-silent to workspaces 1-10 via key codes (layout-independent)
for i = 1, 10 do
    local code = "code:" .. (i + 9)  -- code:10 = key 1 ... code:19 = key 0
    local ws   = i
    hl.bind(mainMod .. " + " .. code,              hl.dsp.focus({ workspace = ws }),                        { description = "workspace " .. ws })
    hl.bind(mainMod .. " + SHIFT + " .. code,      hl.dsp.window.move({ workspace = ws }),                  { description = "move to workspace " .. ws })
    hl.bind(mainMod .. " + CTRL + " .. code,       hl.dsp.window.move({ workspace = ws, silent = true }),   { description = "move silently to workspace " .. ws })
end

hl.bind(mainMod .. " + SHIFT + bracketleft",  hl.dsp.window.move({ workspace = -1 }),               { description = "move to previous workspace" })
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.window.move({ workspace = 1 }),                 { description = "move to next workspace" })
hl.bind(mainMod .. " + CTRL + bracketleft",   hl.dsp.window.move({ workspace = -1, silent = true }), { description = "move silently to previous workspace" })
hl.bind(mainMod .. " + CTRL + bracketright",  hl.dsp.window.move({ workspace = 1,  silent = true }), { description = "move silently to next workspace" })

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "next workspace" })
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { description = "previous workspace" })

-- Move / resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "move window" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "resize window" })

-- ────────────────────────────────────────────────────────────────
-- Menus & launchers
-- ────────────────────────────────────────────────────────────────

hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/launcher.sh"), { description = "launch apps" })

-- ────────────────────────────────────────────────────────────────
-- Window cycling
-- ────────────────────────────────────────────────────────────────

hl.bind("ALT + tab",       hl.dsp.layout("rollnext"),    { description = "cycle next window" })
hl.bind("ALT + tab",       hl.dsp.window.bring_to_top(), { description = "bring active to top" })
hl.bind("SHIFT + ALT + tab", hl.dsp.layout("rollprev"),  { description = "cycle previous window" })
hl.bind("SHIFT + ALT + tab", hl.dsp.window.bring_to_top())

-- ────────────────────────────────────────────────────────────────
-- Convenience
-- ────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(
    [[yad --title="" --no-buttons --undecorated --skip-taskbar --on-top --center --timeout=2 --fixed --width=400 --height=200 --text-align=center --text="<span font='80' weight='bold'>$(date '+%H:%M')\n$(date '+%d/%m')</span>"]]
))

-- Master layout: swap with master + focus master
-- NOTE: the original config also had `movecursortocorner, activecenter`, but
-- `activecenter` is not a valid corner (movecursortocorner only accepts 0-3),
-- so it never worked and was dropped. Re-add hl.dsp.cursor.move_to_corner({ corner = N })
-- with N in 0..3 if you want cursor warping here.
hl.bind(mainMod .. " + CTRL + RETURN", hl.dsp.layout("swapwithmaster"),         { description = "swap with master" })
hl.bind(mainMod .. " + CTRL + RETURN", hl.dsp.layout("focusmaster master"))

-- ────────────────────────────────────────────────────────────────
-- Move focus (hjkl)
-- ────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + ALT + h", hl.dsp.focus({ direction = "l" }), { description = "focus left" })
hl.bind(mainMod .. " + ALT + k", hl.dsp.focus({ direction = "u" }), { description = "focus up" })
hl.bind(mainMod .. " + ALT + l", hl.dsp.focus({ direction = "r" }), { description = "focus right" })
hl.bind(mainMod .. " + ALT + j", hl.dsp.focus({ direction = "d" }), { description = "focus down" })

-- ────────────────────────────────────────────────────────────────
-- Move windows (hjkl)
-- ────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.move({ direction = "l" }), { description = "move window left" })
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.move({ direction = "u" }), { description = "move window up" })
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.move({ direction = "r" }), { description = "move window right" })
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.move({ direction = "d" }), { description = "move window down" })

-- ────────────────────────────────────────────────────────────────
-- Swap windows (hjkl)
-- ────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + SHIFT + CTRL + h", hl.dsp.window.swap({ direction = "l" }), { description = "swap window left" })
hl.bind(mainMod .. " + SHIFT + CTRL + k", hl.dsp.window.swap({ direction = "u" }), { description = "swap window up" })
hl.bind(mainMod .. " + SHIFT + CTRL + l", hl.dsp.window.swap({ direction = "r" }), { description = "swap window right" })
hl.bind(mainMod .. " + SHIFT + CTRL + j", hl.dsp.window.swap({ direction = "d" }), { description = "swap window down" })

-- ────────────────────────────────────────────────────────────────
-- Common app shortcuts
-- ────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + RETURN",    hl.dsp.exec_cmd("uwsm-app -- xdg-terminal-exec"),   { description = "terminal" })
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("uwsm-app -- xdg-open https://"),   { description = "browser" })
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("uwsm-app -- xdg-open ~"),           { description = "file manager" })

-- ────────────────────────────────────────────────────────────────
-- Features / extras
-- ────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + ALT + E",   hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/emojis.sh"),        { description = "emoji menu" })
hl.bind(mainMod .. " + CTRL + S",  hl.dsp.exec_cmd("uwsm-app -- rofi -show window"),                     { description = "window switcher" })
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/game_mode.sh"),     { description = "toggle game mode" })
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/change_layout.sh"), { description = "toggle master/dwindle layout" })
hl.bind(mainMod .. " + ALT + V",   hl.dsp.exec_cmd("uwsm-app -- " .. scriptsDir .. "/clipboard.sh"),     { description = "clipboard manager" })

-- Universal copy/paste/cut/select (macOS-style via Ctrl+Insert / Shift+Insert)
hl.bind(mainMod .. " + C", hl.dsp.send_shortcut({ mods = "CTRL",  key = "Insert", window = "activewindow" }), { description = "copy" })
hl.bind(mainMod .. " + V", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert", window = "activewindow" }), { description = "paste" })
hl.bind(mainMod .. " + X", hl.dsp.send_shortcut({ mods = "CTRL",  key = "X",      window = "activewindow" }), { description = "cut" })
hl.bind(mainMod .. " + A", hl.dsp.send_shortcut({ mods = "CTRL",  key = "A",      window = "activewindow" }), { description = "select all" })

-- Window state
hl.bind(mainMod .. " + CTRL + F",    hl.dsp.window.fullscreen(),                   { description = "fullscreen" })
hl.bind(mainMod .. " + ALT + F",     hl.dsp.window.fullscreen(1),                  { description = "maximize window" })
hl.bind(mainMod .. " + ALT + SPACE", hl.dsp.exec_cmd("uwsm-app -- hyprctl dispatch workspaceopt allfloat"), { description = "float all windows" })

-- Waybar
hl.bind(mainMod .. " + CTRL + ALT + B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"), { description = "toggle waybar on/off" })
