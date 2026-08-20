-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 0,
        border_size = 1,
    },

    decoration = {
        rounding = 5,
    },

    input = {
        accel_profile = "flat",
    },

    misc = {
        focus_on_activate = true,
    },
})

hl.animation({ leaf = "global", enabled = true, speed = 2, bezier = "default" })
