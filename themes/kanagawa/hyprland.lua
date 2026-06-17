-- Theme: active window/group border color.
-- Loaded as current_theme after decorations, so it overrides the wallust default.
local activeBorderColor = "rgb(dcd7ba)"

hl.config({
    general = { col = { active_border = activeBorderColor } },
    group   = { col = { border_active = activeBorderColor } },
})

-- Kanagawa backdrop is too strong for default opacity
hl.window_rule({ match = { tag = "terminal" }, opacity = "0.98 0.95" })
