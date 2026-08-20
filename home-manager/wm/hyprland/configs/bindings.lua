-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local vars = require("vars")
local mod = vars.mod

hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + RETURN", hl.dsp.exec_cmd(vars.terminal))
hl.bind(mod .. " + SHIFT + F", hl.dsp.exec_cmd(vars.filemanager))
hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd(vars.terminal .. " --class=terminal.float -e btop"), { description = "Activity" })

hl.bind(mod .. " + ALT + F", hl.dsp.window.float({ action = "toggle" }))

-- Move focus (and raise the window it lands on), or move the window itself
local directions = {
    { key = "H", direction = "left" },
    { key = "J", direction = "down" },
    { key = "K", direction = "up" },
    { key = "L", direction = "right" },
}

for _, d in ipairs(directions) do
    hl.bind(mod .. " + " .. d.key, hl.dsp.focus({ direction = d.direction }))
    hl.bind(mod .. " + " .. d.key, hl.dsp.window.alter_zorder({ mode = "top" }))
    hl.bind(mod .. " + SHIFT + " .. d.key, hl.dsp.window.move({ direction = d.direction }))
end

hl.bind(mod .. " + M", hl.dsp.exit())

-- Switch workspaces, and move the active window to a workspace
for i = 1, 9 do
    hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + 0", hl.dsp.focus({ workspace = 10 }))
-- carried over as-is from the .conf config; workspace 0 does not exist
hl.bind(mod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 0 }))

hl.bind(mod .. " + TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mod .. " + ALT + L", hl.dsp.exec_cmd("hyprlock"))

hl.bind(mod .. " + SHIFT + 4", hl.dsp.exec_cmd("hyprshot -m region"))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
