-- Media keys.
--
-- Volume and mute go through the wm-audio-* commands, which set state with wpctl
-- and then ping the shell's OSD. The OSD also watches PipeWire directly, so a
-- change made anywhere else raises it too; the ping exists for keypresses that
-- change nothing — volume up at 100%, down at 0 — which would otherwise go
-- unacknowledged.
--
-- Brightness is deliberately unbound. This is a desktop with an external panel
-- and no kernel backlight class, so the old swayosd brightness binds were silent
-- no-ops. Driving the monitor needs ddcutil over DDC/CI; see the display panel.

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wm-audio-output-volume raise"), { repeating = true, locked = true, description = "Volume up" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wm-audio-output-volume lower"), { repeating = true, locked = true, description = "Volume down" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wm-audio-output-volume mute-toggle"), { repeating = true, locked = true, description = "Mute" })
hl.bind("F20", hl.dsp.exec_cmd("wm-audio-input-mute"), { repeating = true, locked = true, description = "Mute microphone" })

-- Precise 1% adjustments with Alt.
hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("wm-audio-output-volume +1"), { repeating = true, locked = true, description = "Volume up precise" })
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("wm-audio-output-volume -1"), { repeating = true, locked = true, description = "Volume down precise" })

-- Cycle the default sink, as Omarchy does on Shift + Mute.
hl.bind("SHIFT + XF86AudioMute", hl.dsp.exec_cmd("wm-audio-output-switch"), { locked = true, description = "Switch audio output" })

-- Player control goes straight to playerctl now that swayosd is gone; the media
-- OSD arrives with the MPRIS widget.
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "Next track" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Pause" })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, description = "Previous track" })
