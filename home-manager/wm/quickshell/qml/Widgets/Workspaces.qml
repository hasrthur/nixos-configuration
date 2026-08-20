// Workspaces 1-7 are persistent (hyprland/configs/workspaces.lua) and each has
// a pinned app (windowrules.lua), so the glyph names the app rather than the
// number. Same icons the waybar bar used, so the swap isn't also a relearn.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland

import qs.Ui

Row {
    id: root

    readonly property var glyphs: ({
        1: "",  // terminal
        2: "",  // code
        3: "",  // chromium
        4: "",  // slack
        5: "",  // vesktop
        6: "",  // spare
        7: ""   // thunderbird
    })

    spacing: 0

    Repeater {
        model: 7

        BarButton {
            required property int index

            readonly property int workspaceId: index + 1
            readonly property var workspace: Hyprland.workspaces.values.find(w => w.id === workspaceId) ?? null
            readonly property bool focused: Hyprland.focusedWorkspace?.id === workspaceId
            readonly property bool occupied: (workspace?.toplevels.values.length ?? 0) > 0

            text: root.glyphs[workspaceId] ?? String(workspaceId)
            active: focused
            // An empty workspace stays readable but recedes.
            opacity: focused || occupied ? 1 : 0.4

            // Lua config: `dispatch` is shorthand for hl.dispatch(...), so the
            // classic "workspace N" dispatcher string does not parse.
            onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + workspaceId + " })")
        }
    }
}
