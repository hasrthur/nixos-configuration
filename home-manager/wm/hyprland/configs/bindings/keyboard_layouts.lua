hl.bind(
    "CTRL + space",
    hl.dsp.exec_cmd("hyprctl switchxkblayout current next"),
    { locked = true, description = "Switch to next keyboard layout" }
)
