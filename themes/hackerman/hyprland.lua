-- Theme: active window/group border color (gradient).
-- Loaded as current_theme after decorations, so it overrides the wallust default.
local activeBorderColor = { colors = { "rgba(26a269ee)", "rgba(2ec27eee)" }, angle = 45 }

hl.config({
    general = { col = { active_border = activeBorderColor } },
    group   = { col = { border_active = activeBorderColor } },
})
