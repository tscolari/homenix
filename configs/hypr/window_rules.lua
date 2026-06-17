-- Window rules and layer rules for Hyprland >= 0.53
-- https://wiki.hypr.land/Configuring/Window-Rules/

-- ====================================================================
-- TAGS - group windows for easier rule application
-- ====================================================================

-- browser
for _, class in ipairs({
    "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$",
    "^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$",
    "^(chrome-.+-Default)$",
    "^([Cc]hromium)$",
    "^([Mm]icrosoft-edge(-stable|-beta|-dev|-unstable))$",
    "^(Brave-browser(-beta|-dev|-unstable)?)$",
    "^([Tt]horium-browser|[Cc]achy-browser)$",
    "^(zen-alpha|zen)$",
}) do
    hl.window_rule({ match = { class = class }, tag = "+browser" })
end

-- screensavers
hl.window_rule({ match = { class = "^jc_reborn$" }, tag = "+screensaver" })

-- calendar / reminders
hl.window_rule({ match = { class = "^org\\.gnome\\.Calendar$" }, tag = "+calendar" })
hl.window_rule({ match = { class = "^evolution-alarm-notify$" }, tag = "+reminders" })

-- notifications
for _, class in ipairs({
    "^(swaync-control-center|swaync-notification-window|swaync-client)$",
}) do
    hl.window_rule({ match = { class = class }, tag = "+notif" })
end

-- KooL settings
hl.window_rule({ match = { title = "^(KooL Hyprland Settings)$" }, tag = "+KooL_Settings" })
for _, class in ipairs({ "^(nwg-displays|nwg-look)$" }) do
    hl.window_rule({ match = { class = class }, tag = "+KooL-Settings" })
end

-- terminals
hl.window_rule({ match = { class = "^(Alacritty|kitty|kitty-dropterm)$" }, tag = "+terminal" })
hl.window_rule({ match = { class = "^(com\\.mitchellh\\.)?ghostty$" }, tag = "+terminal" })

-- email
hl.window_rule({ match = { class = "^([Tt]hunderbird|org.gnome.Evolution)$" }, tag = "+email" })
hl.window_rule({ match = { class = "^(eu.betterbird.Betterbird)$" }, tag = "+email" })

-- projects
for _, class in ipairs({
    "^(codium|codium-url-handler|VSCodium)$",
    "^(VSCode|code-url-handler)$",
    "^(jetbrains-.+)$",
}) do
    hl.window_rule({ match = { class = class }, tag = "+projects" })
end

-- screenshare
hl.window_rule({ match = { class = "^(com.obsproject.Studio)$" }, tag = "+screenshare" })

-- IM
for _, class in ipairs({
    "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$",
    "^([Ff]erdium)$",
    "^([Ww]hatsapp-for-linux)$",
    "^(ZapZap|com.rtosta.zapzap)$",
    "^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$",
    "^(teams-for-linux)$",
    "^(im.riot.Riot|Element)$",
    "^([Ss]lack.*)$",
}) do
    hl.window_rule({ match = { class = class }, tag = "+im" })
end

-- games
hl.window_rule({ match = { class = "^(gamescope)$" }, tag = "+games" })
hl.window_rule({ match = { class = "^(steam_app_\\d+)$" }, tag = "+games" })

-- gamestore
hl.window_rule({ match = { class = "^([Ss]team)$" }, tag = "+gamestore" })
hl.window_rule({ match = { title = "^([Ll]utris)$" }, tag = "+gamestore" })
hl.window_rule({ match = { class = "^(com.heroicgameslauncher.hgl)$" }, tag = "+gamestore" })

-- file manager
hl.window_rule({ match = { class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$" }, tag = "+file-manager" })
hl.window_rule({ match = { class = "^(app.drey.Warp)$" }, tag = "+file-manager" })

-- wallpaper
hl.window_rule({ match = { class = "^([Ww]aytrogen)$" }, tag = "+wallpaper" })

-- multimedia
hl.window_rule({ match = { class = "^([Aa]udacious)$" }, tag = "+multimedia" })

-- multimedia-video
hl.window_rule({ match = { class = "^([Mm]pv|vlc)$" }, tag = "+multimedia_video" })

-- settings
hl.window_rule({ match = { title = "^(ROG Control)$" }, tag = "+settings" })
for _, class in ipairs({
    "^(wihotspot(-gui)?)$",
    "^([Bb]aobab|org.gnome.[Bb]aobab)$",
    "^(gnome-disks|wihotspot(-gui)?)$",
    "^(file-roller|org.gnome.FileRoller)$",
    "^(nm-applet|nm-connection-editor|blueman-manager)$",
    "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$",
    "^(qt5ct|qt6ct|[Yy]ad)$",
    "^(org.kde.polkit-kde-authentication-agent-1)$",
    "^([Rr]ofi)$",
}) do
    hl.window_rule({ match = { class = class }, tag = "+settings" })
end
hl.window_rule({ match = { title = "(Kvantum Manager)" }, tag = "+settings" })
hl.window_rule({ match = { class = "(xdg-desktop-portal-gtk)" }, tag = "+settings" })

-- viewer
hl.window_rule({ match = { class = "^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$" }, tag = "+viewer" })
hl.window_rule({ match = { class = "^(evince)$" }, tag = "+viewer" })
hl.window_rule({ match = { class = "^(eog|org.gnome.Loupe)$" }, tag = "+viewer" })


-- ====================================================================
-- SPECIAL OVERRIDES - using tag matching
-- ====================================================================

hl.window_rule({ match = { tag = "multimedia_video*" }, no_blur = true })
hl.window_rule({ match = { tag = "multimedia_video*" }, opacity = "1.0" })


-- ====================================================================
-- POSITION - using tag matching
-- ====================================================================

hl.window_rule({ match = { class = "^([Tt]hunar)$", title = "negative:.*[Tt]hunar.*" }, center = true })
hl.window_rule({ match = { title = "^(ROG Control)$" }, center = true })
hl.window_rule({ match = { tag = "KooL-Settings*" }, center = true })
hl.window_rule({ match = { title = "^(Keybindings)$" }, center = true })
hl.window_rule({ match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" }, center = true })
hl.window_rule({ match = { class = "^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$" }, center = true })
hl.window_rule({ match = { class = "^([Ff]erdium)$" }, center = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, move = "72% 7%" })


-- ====================================================================
-- FULL SCREENS
-- ====================================================================

hl.window_rule({ match = { tag = "screensaver*" }, fullscreen = true })


-- ====================================================================
-- IDLE INHIBIT
-- ====================================================================

hl.window_rule({ match = { fullscreen = 1, tag = "!screensaver" }, idle_inhibit = "fullscreen" })


-- ====================================================================
-- FLOAT - tag-based
-- ====================================================================

hl.window_rule({ match = { tag = "wallpaper*" },     float = true })
hl.window_rule({ match = { tag = "settings*" },      float = true })
hl.window_rule({ match = { tag = "viewer*" },        float = true })
hl.window_rule({ match = { tag = "KooL-Settings*" }, float = true })
hl.window_rule({ match = { tag = "reminders*" },     float = true })

-- float class-based
hl.window_rule({ match = { class = "^([Zz]oom|onedriver|onedriver-launcher)$" }, float = true })
hl.window_rule({ match = { class = "^(org.gnome.Calculator)$", title = "^(Calculator)$" }, float = true })
hl.window_rule({ match = { class = "^(mpv|com.github.rafostar.Clapper)$" }, float = true })
hl.window_rule({ match = { class = "^([Qq]alculate-gtk)$" }, float = true })
hl.window_rule({ match = { class = "^([Ff]erdium)$" }, float = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true })


-- ====================================================================
-- FLOAT POPUPS AND DIALOGUES
-- ====================================================================

hl.window_rule({ match = { title = "^(Authentication Required)$" }, float = true })
hl.window_rule({ match = { title = "^(Authentication Required)$" }, center = true })

-- VSCodium popups
hl.window_rule({ match = { class = "^(codium|codium-url-handler|VSCodium)$", title = "negative:.*(codium|VSCodium).*" }, float = true })

-- Heroic popups
hl.window_rule({ match = { class = "^(com.heroicgameslauncher.hgl)$", title = "negative:^(Heroic Games Launcher)$" }, float = true })

-- Steam popups
hl.window_rule({ match = { class = "^([Ss]team)$", title = "negative:^([Ss]team)$" }, float = true })

-- Thunar popups
hl.window_rule({ match = { class = "^([Tt]hunar)$", title = "negative:.*[Tt]hunar.*" }, float = true })

-- Add Folder to Workspace dialog
hl.window_rule({ match = { title = "^(Add Folder to Workspace)$" }, float = true })
hl.window_rule({ match = { title = "^(Add Folder to Workspace)$" }, size = "70% 60%" })
hl.window_rule({ match = { title = "^(Add Folder to Workspace)$" }, center = true })

-- Save As dialog
hl.window_rule({ match = { title = "^(Save As)$" }, float = true })
hl.window_rule({ match = { title = "^(Save As)$" }, size = "70% 60%" })
hl.window_rule({ match = { title = "^(Save As)$" }, center = true })

-- Open Files dialog
hl.window_rule({ match = { initial_title = "^(Open Files)$" }, float = true })
hl.window_rule({ match = { initial_title = "^(Open Files)$" }, size = "70% 60%" })

-- SDDM Background (YAD)
hl.window_rule({ match = { title = "^(SDDM Background)$" }, float = true })
hl.window_rule({ match = { title = "^(SDDM Background)$" }, center = true })
hl.window_rule({ match = { title = "^(SDDM Background)$" }, size = "16% 12%" })


-- ====================================================================
-- OPACITY - tag-based
-- ====================================================================

for _, tag in ipairs({
    "browser*", "projects*", "im*", "multimedia*",
    "file-manager*", "terminal*", "settings*", "viewer*", "wallpaper*",
}) do
    hl.window_rule({ match = { tag = tag }, opacity = "1.0 0.9" })
end

hl.window_rule({ match = { class = "^(gedit|org.gnome.TextEditor|mousepad)$" }, opacity = "1.0 0.9" })
hl.window_rule({ match = { class = "^(deluge)$" },    opacity = "1.0 0.9" })
hl.window_rule({ match = { class = "^(seahorse)$" },  opacity = "1.0 0.9" })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, opacity = "1.0 0.9" })
hl.window_rule({ match = { class = "^(code)$" },      opacity = "1.0 0.8" })


-- ====================================================================
-- SIZE
-- ====================================================================

hl.window_rule({ match = { tag = "wallpaper*" }, size = "70% 70%" })
hl.window_rule({ match = { tag = "settings*" },  size = "70% 70%" })
hl.window_rule({ match = { class = "^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$" }, size = "60% 70%" })
hl.window_rule({ match = { class = "^([Ff]erdium)$" }, size = "60% 70%" })


-- ====================================================================
-- PIN / EXTRAS
-- ====================================================================

hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, pin = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, keep_aspect_ratio = true })


-- ====================================================================
-- BLUR & GAME
-- ====================================================================

hl.window_rule({ match = { tag = "games*" }, no_blur = true })


-- ====================================================================
-- LAYER RULES
-- ====================================================================

hl.layer_rule({ match = { namespace = "rofi" },                  blur = true })
hl.layer_rule({ match = { namespace = "rofi" },                  ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "notifications" },         blur = true })
hl.layer_rule({ match = { namespace = "notifications" },         ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "quickshell:overview" },   blur = true })
hl.layer_rule({ match = { namespace = "quickshell:overview" },   ignore_alpha = 0.5 })
