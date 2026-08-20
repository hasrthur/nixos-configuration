// Bar contents: three sections on a fixed top edge.
//
// The centre section is anchored to the bar's own centre rather than balanced
// between two flexible spacers, so the clock stays put as widgets are added to
// either side.
import QtQuick

import qs.Commons
import qs.Widgets

Item {
    id: root

    Row {
        id: left

        anchors.left: parent.left
        anchors.leftMargin: Theme.edgeGap
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.widgetGap

        Workspaces {}
    }

    Row {
        id: center

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.widgetGap

        Clock {}
    }

    Row {
        id: right

        anchors.right: parent.right
        anchors.rightMargin: Theme.edgeGap
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.widgetGap

        Tray {}
        KeyboardLayout {}
        Bluetooth {}
        Network {}
        Audio {}
        Microphone {}
        Cpu {}
    }
}
