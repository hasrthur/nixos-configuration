// Status notifier items. Left click activates, middle click is the item's
// secondary action, right click opens its menu — drawn by qs.Ui.Menu rather than
// handed to Qt, so it matches the bar.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell.Services.SystemTray

import qs.Commons
import qs.Ui

Row {
    id: root

    spacing: 0

    Repeater {
        model: SystemTray.items

        Item {
            id: entry

            required property SystemTrayItem modelData

            // Passive means the app has nothing to say right now — udiskie sits
            // passive until a drive appears. Rendering it anyway leaves a dead
            // glyph on the bar.
            visible: modelData.status !== Status.Passive
            implicitWidth: visible ? Theme.barHeight : 0
            implicitHeight: Theme.barHeight

            // Decoded at physical pixels rather than logical ones. IconImage sizes
            // by the logical value, so a themed PNG gets upscaled from whichever
            // file is nearest below — a 22px icon asked for at 18px came back as
            // the 16px one, blurred and washed out enough to look disabled.
            readonly property bool symbolic: String(entry.modelData.icon ?? "").split("?")[0].endsWith("-symbolic")

            Image {
                id: icon

                anchors.centerIn: parent
                width: Theme.trayIconSize
                height: Theme.trayIconSize
                fillMode: Image.PreserveAspectFit
                sourceSize.width: Math.round(Theme.trayIconSize * Screen.devicePixelRatio)
                sourceSize.height: Math.round(Theme.trayIconSize * Screen.devicePixelRatio)
                source: entry.modelData.icon
                asynchronous: true
                // Symbolic icons ship a fixed fill the host is meant to replace,
                // so they are hidden here and drawn tinted by the effect below.
                visible: !entry.symbolic
                layer.enabled: entry.symbolic
            }

            MultiEffect {
                anchors.fill: icon
                source: icon
                visible: entry.symbolic
                colorization: 1.0
                colorizationColor: Theme.foreground
            }

            // Items name icons by theme id, and a theme is never guaranteed to
            // carry all of them. Fall back to a glyph so the item stays usable.
            Text {
                anchors.centerIn: parent
                visible: icon.status !== Image.Ready
                text: "\u25cf"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pointSize: Theme.fontSize
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                onClicked: function (event) {
                    if (event.button === Qt.RightButton) {
                        if (itemMenu.visible) {
                            itemMenu.close();
                        } else if (entry.modelData.hasMenu) {
                            itemMenu.handle = entry.modelData.menu;
                            itemMenu.visible = true;
                        }
                    } else if (event.button === Qt.MiddleButton) {
                        entry.modelData.secondaryActivate();
                    } else {
                        entry.modelData.activate();
                    }
                }
            }

            Menu {
                id: itemMenu

                anchorItem: entry
                titleHint: entry.modelData.title ?? ""
            }
        }
    }
}
