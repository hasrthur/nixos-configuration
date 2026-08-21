// Entry point for the desktop shell.
//
// Deliberately not configurable at runtime: the layout is this code. There is
// no plugin registry, no manifest scanning and no config file to parse, because
// this shell serves exactly one machine whose bar we already know the shape of.
import Quickshell

import qs.Commons

ShellRoot {
    Launcher {}
    Notifications {}
    Osd {}

    // One bar per output. Quickshell rebuilds the set as monitors come and go.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData

            // Top edge, always. Reserves its own space so windows tile below it.
            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: Theme.barHeight
            color: Theme.barBackground

            Bar {
                anchors.fill: parent
            }
        }
    }
}
