// Bluetooth radio and connected-device count.
//
// waybar drew the same glyph whether or not anything was connected and put the
// count in a tooltip. We have no tooltips, so the count goes inline and the glyph
// takes the accent colour while something is attached — strictly more legible,
// and it needs no glyph the font might not carry.
//
// Left click opens the device picker, right click toggles the radio (Omarchy's
// gesture). The picker is bzmenu for now and goes away with the bluetooth panel.
import QtQuick
import Quickshell.Io
import Quickshell.Bluetooth

import qs.Commons
import qs.Ui

BarButton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool radioOn: adapter?.enabled ?? false
    readonly property int connectedCount: (Bluetooth.devices?.values ?? []).filter(d => d.connected).length

    // Glyphs as escapes; the "off" one sits above the BMP so it needs a pair.
    readonly property string glyphOn: "\uf294"
    readonly property string glyphOff: "\udb80\udcb2"

    // Nothing to show on a machine with no bluetooth hardware at all.
    visible: adapter !== null
    text: !radioOn ? glyphOff
        : connectedCount > 0 ? glyphOn + " " + connectedCount
        : glyphOn
    textColor: !radioOn ? Theme.muted
             : connectedCount > 0 ? Theme.accent
             : Theme.foreground

    onClicked: picker.running = true
    onRightClicked: if (adapter) adapter.enabled = !adapter.enabled

    Process {
        id: picker

        command: ["bzmenu", "-l", "rofi"]
    }
}
