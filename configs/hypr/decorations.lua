-- Decoration settings
-- Requires wallust color globals to be loaded first (wallust.wallust-hyprland)
-- https://wiki.hypr.land/Configuring/Variables/#decoration

hl.config({
    general = {
        border_size = 3,
        gaps_in     = 1,
        gaps_out    = 1,
        col = {
            active_border   = color6,
            inactive_border = "rgba(00000000)",
        },
    },

    decoration = {
        rounding          = 3,
        active_opacity    = 1.0,
        inactive_opacity  = 1.0,
        fullscreen_opacity = 1.0,
        dim_inactive      = false,
        dim_strength      = 0.0,
        dim_special       = 0.0,

        shadow = {
            enabled      = false,
            range        = 1,
            render_power = 1,
            color        = color12,
            color_inactive = color10,
        },

        blur = {
            enabled          = true,
            size             = 6,
            passes           = 2,
            ignore_opacity   = true,
            new_optimizations = true,
            special          = true,
            popups           = true,
        },
    },

    group = {
        col = {
            border_active = color15,
        },
        groupbar = {
            col = {
                active = color0,
            },
        },
    },
})
