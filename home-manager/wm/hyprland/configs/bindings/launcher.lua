local vars = require("vars")
local mod = vars.mod

-- combi -modes combi -combi-modes "window,drun,run"
hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd("rofi -show-icons -show drun"))
hl.bind(mod .. " + SHIFT + ESCAPE", hl.dsp.exec_cmd("rofi -show power-menu -modi power-menu:rofi-power-menu"))
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("bzmenu -l rofi"))
hl.bind(mod .. " + SHIFT + A", hl.dsp.exec_cmd("pwmenu -l rofi"))
