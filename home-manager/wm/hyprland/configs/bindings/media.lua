-- Only display the OSD on the currently focused monitor
local osdclient = [[swayosd-client --monitor "$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')"]]

local function osd(args)
    return hl.dsp.exec_cmd(osdclient .. " " .. args)
end

-- Laptop multimedia keys for volume and LCD brightness (with OSD)
hl.bind("XF86AudioRaiseVolume", osd("--output-volume raise"), { repeating = true, locked = true, description = "Volume up" })
hl.bind("XF86AudioLowerVolume", osd("--output-volume lower"), { repeating = true, locked = true, description = "Volume down" })
hl.bind("XF86AudioMute", osd("--output-volume mute-toggle"), { repeating = true, locked = true, description = "Mute" })
hl.bind("F20", osd("--input-volume mute-toggle"), { repeating = true, locked = true, description = "Mute microphone" })
hl.bind("XF86MonBrightnessUp", osd("--brightness raise"), { repeating = true, locked = true, description = "Brightness up" })
hl.bind("XF86MonBrightnessDown", osd("--brightness lower"), { repeating = true, locked = true, description = "Brightness down" })

-- Precise 1% multimedia adjustments with Alt modifier
hl.bind("ALT + XF86AudioRaiseVolume", osd("--output-volume +1"), { repeating = true, locked = true, description = "Volume up precise" })
hl.bind("ALT + XF86AudioLowerVolume", osd("--output-volume -1"), { repeating = true, locked = true, description = "Volume down precise" })
hl.bind("ALT + XF86MonBrightnessUp", osd("--brightness +1"), { repeating = true, locked = true, description = "Brightness up precise" })
hl.bind("ALT + XF86MonBrightnessDown", osd("--brightness -1"), { repeating = true, locked = true, description = "Brightness down precise" })

-- Requires playerctl
hl.bind("XF86AudioNext", osd("--playerctl next"), { locked = true, description = "Next track" })
hl.bind("XF86AudioPause", osd("--playerctl play-pause"), { locked = true, description = "Pause" })
hl.bind("XF86AudioPlay", osd("--playerctl play-pause"), { locked = true, description = "Play" })
hl.bind("XF86AudioPrev", osd("--playerctl previous"), { locked = true, description = "Previous track" })

-- Switch audio output with Super + Mute
-- hl.bind("SUPER + XF86AudioMute", hl.dsp.exec_cmd("omarchy-cmd-audio-switch"), { locked = true, description = "Switch audio output" })
