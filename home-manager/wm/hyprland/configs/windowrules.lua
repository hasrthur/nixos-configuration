-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.window_rule({
    name = "suppress-maximize",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- Floating windows
hl.window_rule({
    name = "floating-window",
    match = { tag = "floating-window" },

    float = true,
    center = true,
    size = { "monitor_w*0.8", "monitor_h*0.8" },
})

hl.window_rule({
    name = "tag-floating-apps",
    match = { class = "(terminal.float|org.gnome.Nautilus|org.gnome.NautilusPreviewer|blueberry.py)" },

    tag = "+floating-window",
})

hl.window_rule({
    name = "tag-file-dialogs",
    match = {
        class = "(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus|chromium|code)",
        title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files)",
    },

    tag = "+floating-window",
})

-- Fullscreen screensaver
hl.window_rule({
    name = "fullscreen-screensaver",
    match = { class = "Screensaver" },

    fullscreen = true,
})

-- Default workspaces
local defaultWorkspaces = {
    { class = "(com.mitchellh.ghostty)", workspace = 1 },
    { class = "(code)", workspace = 2 },
    { class = "(chromium-browser)", workspace = 3 },
    { class = "(Slack)", workspace = 4 },
    { class = "(vesktop)", workspace = 5 },
    { class = "(thunderbird)", workspace = 7 },
}

for _, rule in ipairs(defaultWorkspaces) do
    hl.window_rule({
        name = "workspace-" .. rule.workspace .. "-" .. rule.class,
        match = { class = rule.class },

        workspace = tostring(rule.workspace),
    })
end

-- -- Zoom Workplace Screen Sharing
-- -- Sharing Toolbar
-- hl.window_rule({
--     name = "zoom-sharing-toolbar",
--     match = { class = "^(Zoom Workplace)$", title = "^(as_toolbar)$" },
--
--     float = true,
--     border_size = 0,
--     no_shadow = true,
--     move = { 930, 85 },
-- })
--
-- -- Zoom Workplace Screen Sharing
-- -- Green Border Selection
-- hl.window_rule({
--     name = "zoom-sharing-frame",
--     match = { title = "^(cpt_frame_xcb_window)$" },
--
--     float = true,
--     border_size = 0,
-- })
--
-- -- Zoom Workplace
-- -- Main Zoom Landing Window
-- hl.window_rule({
--     name = "zoom-landing",
--     match = { class = "^(Zoom Workplace)$", title = "^(Zoom Workplace - Licensed account)$" },
--
--     float = true,
--     size = { 660, 530 },
--     center = true,
-- })
--
-- -- Zoom Workplace Settings
-- hl.window_rule({
--     name = "zoom-settings",
--     match = { class = "^(Zoom Workplace)$", title = "^(Settings)$" },
--
--     float = true,
-- })
--
-- -- Zoom Workplace Menu Windows
-- -- Audio Settings, Video Settings, Gallery View etc..
-- hl.window_rule({
--     name = "zoom-menu",
--     match = { class = "^(Zoom Workplace)$", title = "^(menu window)$" },
--
--     float = true,
--     size = { 300, 600 },
--     stay_focused = true,
--     center = true,
-- })
--
-- -- Zoom Workplace Top Bar Popups
-- -- Zoom Meeting Info Window
-- hl.window_rule({
--     name = "zoom-topbar-popup",
--     match = { class = "^(Zoom Workplace)$", title = "^(meeting topbar popup)$" },
--
--     float = true,
--     border_size = 0,
--     no_shadow = true,
--     center = true,
--     stay_focused = true,
--     size = { 485, 442 },
-- })
--
-- -- Zoom Workplace Bottom Bar Popups
-- -- Zoom Reactions
-- hl.window_rule({
--     name = "zoom-bottombar-popup",
--     match = { class = "^(Zoom Workplace)$", title = "^(meeting bottombar popup)$" },
--
--     float = true,
--     border_size = 0,
--     no_shadow = true,
--     center = true,
--     stay_focused = true,
--     size = { 285, 90 },
-- })
--
-- -- Zoom Workplace Misc
-- -- Captions Window, Breakout Room Creation, etc
-- hl.window_rule({
--     name = "zoom-misc",
--     match = { class = "^(Zoom Workplace)$", title = "^(zoom)$" },
--
--     float = true,
--     border_size = 0,
--     no_shadow = true,
--     center = true,
-- })
--
-- -- Zoom Workplace
-- -- Participants Window (Detached)
-- hl.window_rule({
--     name = "zoom-participants",
--     match = { class = "^(Zoom Workplace)$", title = "^(Participants)(.*)$" },
--
--     float = true,
--     size = { 490, 550 },
--     center = true,
-- })
--
-- -- Zoom Workplace
-- -- Chat Window (Detached)
-- hl.window_rule({
--     name = "zoom-chat",
--     match = { class = "^(Zoom Workplace)$", title = "^(Meeting chat)$" },
--
--     float = true,
--     size = { 490, 550 },
--     center = true,
-- })
