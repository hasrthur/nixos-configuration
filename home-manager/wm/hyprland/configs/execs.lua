-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
local vars = require("vars")

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- hyprland-per-window-layout")

    hl.exec_cmd(vars.terminal)
    hl.exec_cmd("uwsm app -- code")
    hl.exec_cmd("uwsm app -- " .. vars.browser)
    hl.exec_cmd("uwsm app -- slack --ozone-platform=wayland")
    hl.exec_cmd("uwsm app -- vesktop")
    hl.exec_cmd("uwsm app -- birdtray")
    hl.exec_cmd("uwsm app -- thunderbird")
end)
