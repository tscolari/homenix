-- Theme: active window/group border color.
-- Loaded as current_theme after decorations, so it overrides the wallust default.
local activeBorderColor = "rgb(a89984)"

hl.config({
    general = { col = { active_border = activeBorderColor } },
    group   = { col = { border_active = activeBorderColor } },
})
