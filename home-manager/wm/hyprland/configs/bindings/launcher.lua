-- The menu.
--
-- One searchable tree covers apps, actions and toggles, so a single key does most
-- things. Omarchy took the same route: v4 uninstalls walker and its elephant-*
-- providers and answers SUPER + SPACE with its own menu.
--
-- bzmenu and pwmenu keep their keys until the bluetooth and audio panels land;
-- rofi stays installed for pinentry, which is the last thing holding it.
local vars = require("vars")
local mod = vars.mod

hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd("wm-shell menu toggle root"), { description = "Menu" })
hl.bind(mod .. " + ALT + SPACE", hl.dsp.exec_cmd("wm-shell menu toggle apps"), { description = "Apps" })
hl.bind(mod .. " + SHIFT + ESCAPE", hl.dsp.exec_cmd("wm-shell menu toggle system"), { description = "System menu" })

hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("bzmenu -l rofi"), { description = "Bluetooth" })
hl.bind(mod .. " + SHIFT + A", hl.dsp.exec_cmd("pwmenu -l rofi"), { description = "Audio devices" })
