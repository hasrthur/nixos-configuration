// Hyprland exposes no property for the active layout, so it has to be read back
// from `hyprctl devices` each time the activelayout event fires. Hidden entirely
// while only one layout is configured.
import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

import qs.Ui

BarButton {
    id: root

    property string layout: ""

    function shortName(keymap) {
        if (keymap.startsWith("Ukrainian")) return "ua";
        if (keymap.startsWith("English")) return "en";
        return keymap.slice(0, 2).toLowerCase();
    }

    visible: layout !== ""
    text: layout

    // Not a dispatcher: switchxkblayout is its own hyprctl command.
    onClicked: switchLayout.running = true

    Process {
        id: switchLayout

        command: ["hyprctl", "switchxkblayout", "current", "next"]
    }

    Process {
        id: devices

        command: ["hyprctl", "-j", "devices"]

        stdout: StdioCollector {
            onStreamFinished: {
                let keyboards = [];
                try {
                    keyboards = JSON.parse(text).keyboards ?? [];
                } catch (e) {
                    return;
                }

                // Hyprland reports virtual devices as keyboards too, so prefer
                // the one it marks as main.
                const main = keyboards.find(k => k.main) ?? keyboards[0];
                if (main?.active_keymap) root.layout = root.shortName(main.active_keymap);
            }
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "activelayout") devices.running = true;
        }
    }

    Component.onCompleted: devices.running = true
}
