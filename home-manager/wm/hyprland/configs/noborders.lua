-- no borders when there is only one window on the workspace
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })

hl.window_rule({
    name = "no-borders-w-tv1",
    match = { float = false, workspace = "w[tv1]" },

    border_size = 0,
    rounding = 0,
})

hl.window_rule({
    name = "no-borders-f1",
    match = { float = false, workspace = "f[1]" },

    border_size = 0,
    rounding = 0,
})

-- The launcher's backdrop covers the screen, so blurring it blurs the desktop
-- behind the menu. It carries its own layer namespace precisely so this rule
-- does not also hit the bar, which shares the default "quickshell" one.
hl.layer_rule({
    name = "launcher-blur",
    match = { namespace = "wm-launcher" },

    blur = true,
})
