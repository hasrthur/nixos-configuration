-- Notification control, on the comma key as in Omarchy.
--
-- History is a replay rather than a panel: showHistory brings the last ten back
-- as cards for a few seconds. Neither Omarchy nor this shell has a notification
-- centre.
local vars = require("vars")
local mod = vars.mod

hl.bind(mod .. " + comma", hl.dsp.exec_cmd("wm-shell notifications dismissLast"), { description = "Dismiss last notification" })
hl.bind(mod .. " + SHIFT + comma", hl.dsp.exec_cmd("wm-shell notifications dismissAll"), { description = "Dismiss all notifications" })
hl.bind(mod .. " + ALT + comma", hl.dsp.exec_cmd("wm-shell notifications invokeLast"), { description = "Invoke last notification" })
hl.bind(mod .. " + CTRL + comma", hl.dsp.exec_cmd("wm-shell notifications toggleSilence"), { description = "Toggle silencing notifications" })
hl.bind(mod .. " + SHIFT + ALT + comma", hl.dsp.exec_cmd("wm-shell notifications showHistory"), { description = "Replay notification history" })
hl.bind(mod .. " + SHIFT + CTRL + comma", hl.dsp.exec_cmd("wm-shell notifications clearHistory"), { description = "Clear notification history" })
