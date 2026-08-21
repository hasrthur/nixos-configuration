-- Notification control, on the comma key as in Omarchy.
--
-- History replay (their SUPER + SHIFT + ALT + comma) is deliberately absent: it
-- needs on-disk persistence, which is most of the difference between their
-- notification service and ours, and it only earns that once silencing has been
-- lived with long enough to miss something behind it.
local vars = require("vars")
local mod = vars.mod

hl.bind(mod .. " + comma", hl.dsp.exec_cmd("wm-shell notifications dismissLast"), { description = "Dismiss last notification" })
hl.bind(mod .. " + SHIFT + comma", hl.dsp.exec_cmd("wm-shell notifications dismissAll"), { description = "Dismiss all notifications" })
hl.bind(mod .. " + ALT + comma", hl.dsp.exec_cmd("wm-shell notifications invokeLast"), { description = "Invoke last notification" })
hl.bind(mod .. " + CTRL + comma", hl.dsp.exec_cmd("wm-shell notifications toggleSilence"), { description = "Toggle silencing notifications" })
