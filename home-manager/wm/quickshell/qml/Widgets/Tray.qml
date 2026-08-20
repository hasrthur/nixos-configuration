// Status notifier items. QsMenuAnchor renders the item's own DBus menu, so there
// is no menu model to build here: left click activates, middle click is the
// item's secondary action, right click opens its menu.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import qs.Commons

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
                        if (entry.modelData.hasMenu) itemMenu.open();
                    } else if (event.button === Qt.MiddleButton) {
                        entry.modelData.secondaryActivate();
                    } else {
                        entry.modelData.activate();
                    }
                }
            }

            QsMenuAnchor {
                id: itemMenu

                menu: entry.modelData.menu
                anchor.item: entry
            }
        }
    }
}
