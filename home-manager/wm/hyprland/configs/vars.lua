-- Values shared between the Hyprland Lua config modules.
-- Loaded explicitly with `require("vars")`, not auto-loaded.
return {
    mod = "SUPER",
    terminal = "uwsm-app -- $TERMINAL",
    browser = "uwsm-app -- chromium",
    filemanager = "uwsm-app -- nautilus",
}
