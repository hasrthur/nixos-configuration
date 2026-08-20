-- Copy / Paste
local vars = require("vars")

hl.bind("SUPER + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" }), { description = "Copy" })
hl.bind("SUPER + V", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" }), { description = "Paste" })
hl.bind("SUPER + X", hl.dsp.send_shortcut({ mods = "CTRL", key = "X" }), { description = "Cut" })

hl.bind(
    vars.mod .. " + SHIFT + V",
    hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"),
    { description = "Clipboard history" }
)
