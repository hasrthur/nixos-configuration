// Status notifier items. Left click activates, middle click is the item's
// secondary action, right click opens its menu — drawn by qs.Ui.Menu rather than
// handed to Qt, so it matches the bar.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets

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

            implicitWidth: Theme.barHeight
            implicitHeight: Theme.barHeight

            IconImage {
                id: icon

                anchors.centerIn: parent
                implicitSize: Theme.trayIconSize
                source: entry.modelData.icon
                asynchronous: true
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
