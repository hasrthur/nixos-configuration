-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 0,
        border_size = 1,
    },

    decoration = {
        rounding = 5,

        -- Enabled for the launcher's backdrop, which is the only thing that asks
        -- for it: the layer rule below is what actually turns it on for that one
        -- surface. Omarchy disables blur outright, so this is a deliberate
        -- divergence rather than an oversight.
        blur = {
            enabled = true,
            size = 5,
            passes = 1,
        },
    },

    input = {
        accel_profile = "flat",
    },

    misc = {
        focus_on_activate = true,
    },
})

hl.animation({ leaf = "global", enabled = true, speed = 2, bezier = "default" })
