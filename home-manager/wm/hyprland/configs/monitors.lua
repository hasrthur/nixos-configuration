-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output = "desc:ASUSTek COMPUTER INC PA27JCV T5LMSB027544",
    mode = "5120x2880@60",
    position = "auto",
    scale = "2.5",
})

-- hl.monitor({
--     output = "desc:LG Electronics LG HDR 4K 0x0002DA7E",
--     mode = "3840x2160@60",
--     position = "auto",
--     scale = "2",
--     bitdepth = 10,
-- })

hl.monitor({ output = "Unknown-1", disabled = true })

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
