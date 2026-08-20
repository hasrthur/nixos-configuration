// Link state. Wired and wifi are shown independently rather than one winning,
// so a machine on both reads as being on both. Falls back to a single
// disconnected glyph when neither is up. Same glyphs the waybar module used.
//
// Quickshell.Networking is event-driven, so there is no poll interval to set —
// waybar needed `interval: 3` only because it shelled out.
//
// Clicking opens nmtui in a floating terminal. That is a stopgap: the network
// panel replaces it, and Omarchy has no launcher-based picker at all.
import QtQuick
import Quickshell.Io
import Quickshell.Networking

import qs.Commons
import qs.Ui

Row {
    id: root

    readonly property var devices: Networking.devices?.values ?? []

    readonly property var wired: devices.find(d => d.type === DeviceType.Wired && d.connected) ?? null
    readonly property var wifiDevice: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wifiNetwork: wifiDevice?.networks?.values?.find(n => n.connected) ?? null

    // Nerd Font glyphs are surrogate pairs: these codepoints sit above the BMP.
    readonly property var wifiRamp: [
        "\udb82\udd2f",
        "\udb82\udd1f",
        "\udb82\udd22",
        "\udb82\udd25",
        "\udb82\udd28"
    ]

    // Quickshell reports signalStrength as a 0-1 fraction, not the 0-100 percent
    // nmcli prints. Accept either, so a change of units cannot silently pin the
    // glyph to "no signal". Bucket edges follow Omarchy's: ceil(pct / 20) - 1.
    function strengthIndex(raw) {
        const pct = (raw ?? 0) <= 1 ? (raw ?? 0) * 100 : raw;
        return Math.max(0, Math.min(wifiRamp.length - 1, Math.ceil(pct / 20) - 1));
    }

    // A limited or captive connection is worth flagging: the glyph alone would
    // claim everything is fine.
    readonly property color linkColor: Networking.connectivity === NetworkConnectivity.Full
                                       ? Theme.foreground : Theme.warning

    // Wired and wifi are separately clickable, so they space like peers rather
    // than crowding into one glyph pair.
    spacing: Theme.widgetGap

    BarButton {
        visible: root.wired !== null
        text: "\udb80\udc02"
        textColor: root.linkColor

        onClicked: editor.running = true
    }

    BarButton {
        visible: root.wifiNetwork !== null
        text: root.wifiRamp[root.strengthIndex(root.wifiNetwork?.signalStrength)]
        textColor: root.linkColor

        onClicked: editor.running = true
    }

    BarButton {
        visible: root.wired === null && root.wifiNetwork === null
        text: "\udb82\udd2e"
        textColor: Theme.muted

        onClicked: editor.running = true
    }

    Process {
        id: editor

        command: ["ghostty", "--class=terminal.float", "-e", "nmtui"]
    }
}
