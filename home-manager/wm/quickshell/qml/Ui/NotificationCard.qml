// One notification card, driven by explicit values rather than a Notification
// object, so the same component renders a live notification and a replayed
// history entry. History snapshots have no object behind them.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets

import qs.Commons

Rectangle {
    id: root

    property string appName: ""
    property string summary: ""
    property string body: ""
    property bool critical: false
    // [{ text, invoke }] for live notifications; empty for history, whose
    // actions belong to a process that has long since moved on.
    property var actionModel: []
    property bool replayed: false
    // The notification's own image (an avatar, album art) if it sent one,
    // otherwise its app icon. Empty for senders that provide neither.
    property string iconSource: ""

    signal dismissRequested
    signal defaultRequested

    implicitHeight: Math.max(content.implicitHeight,
                             icon.visible ? Theme.notificationIconSize : 0) + Theme.menuPadding * 2
    height: implicitHeight
    color: Theme.menuBackground
    radius: Theme.menuRadius
    border.width: Theme.menuBorderWidth
    // Critical is the one urgency worth colouring, and the one that will not
    // leave on its own.
    border.color: root.critical ? Theme.urgent : Theme.menuBorder
    // A replayed card is a record, not an event: it reads quieter.
    opacity: root.replayed ? 0.85 : 1

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function (event) {
            if (event.button === Qt.LeftButton) root.defaultRequested();
            else root.dismissRequested();
        }
    }

    IconImage {
        id: icon

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: Theme.menuPadding
        anchors.topMargin: Theme.menuPadding
        implicitSize: Theme.notificationIconSize
        visible: root.iconSource !== ""
        source: root.iconSource
        asynchronous: true
    }

    Column {
        id: content

        anchors.left: icon.visible ? icon.right : parent.left
        anchors.leftMargin: Theme.menuPadding
        anchors.right: parent.right
        anchors.rightMargin: Theme.menuPadding
        anchors.top: parent.top
        anchors.topMargin: Theme.menuPadding
        spacing: 4

        Text {
            width: parent.width
            visible: text !== ""
            text: root.replayed && root.appName !== "" ? root.appName + " · earlier"
                : root.replayed ? "earlier"
                : root.appName
            color: root.critical ? Theme.urgent : Theme.muted
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pointSize: Theme.fontSize - 2
        }

        Text {
            width: parent.width
            visible: text !== ""
            text: root.summary
            color: Theme.emphasis
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pointSize: Theme.fontSize
        }

        Text {
            width: parent.width
            visible: text !== ""
            text: root.body
            color: Theme.foreground
            wrapMode: Text.WordWrap
            maximumLineCount: 6
            elide: Text.ElideRight
            textFormat: Text.StyledText
            font.family: Theme.fontFamily
            font.pointSize: Theme.fontSize - 1
        }

        Row {
            spacing: Theme.menuGap
            visible: root.actionModel.length > 0
            topPadding: 4

            Repeater {
                model: root.actionModel

                Rectangle {
                    id: button

                    required property var modelData

                    implicitWidth: label.implicitWidth + Theme.menuPadding * 2
                    implicitHeight: Math.round(Theme.fontSize * 2)
                    radius: Math.max(2, Theme.menuRadius - 2)
                    color: hover.containsMouse ? Theme.menuHighlight : "transparent"
                    border.width: 1
                    border.color: Theme.menuBorder

                    Text {
                        id: label

                        anchors.centerIn: parent
                        text: button.modelData.text ?? ""
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pointSize: Theme.fontSize - 1
                    }

                    MouseArea {
                        id: hover

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: button.modelData.invoke()
                    }
                }
            }
        }
    }
}
