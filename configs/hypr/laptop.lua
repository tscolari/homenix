-- Laptop-specific settings
-- https://wiki.hypr.land/Configuring/Variables/

local scriptsDir    = os.getenv("HOME") .. "/.config/hypr/scripts"
local touchpadDevice = "asue1209:00-04f3:319f-touchpad"

hl.device({
    name    = touchpadDevice,
    enabled = true,
})

-- Keyboard brightness
hl.bind("xf86KbdBrightnessDown", hl.dsp.exec_cmd(scriptsDir .. "/brightness_keyboard.sh --dec"), { repeating = true })
hl.bind("xf86KbdBrightnessUp",   hl.dsp.exec_cmd(scriptsDir .. "/brightness_keyboard.sh --inc"), { repeating = true })

-- Monitor brightness
hl.bind("xf86MonBrightnessDown", hl.dsp.exec_cmd(scriptsDir .. "/brightness.sh --dec"), { repeating = true })
hl.bind("xf86MonBrightnessUp",   hl.dsp.exec_cmd(scriptsDir .. "/brightness.sh --inc"), { repeating = true })

-- Lid switch
-- Lid handling lives in lid_switch.sh: on close it disables the internal panel ONLY when an
-- external monitor is connected. Laptop-only it does nothing and logind suspends.
hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd(scriptsDir .. "/lid_switch.sh close"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd(scriptsDir .. "/lid_switch.sh open"),  { locked = true })
