// A bar cell: full bar height, hover feedback, and the three mouse buttons plus
// scroll surfaced as signals. Widgets that are only ever text use this directly;
// widgets that draw something else keep the MouseArea and skip the label.
import QtQuick

import qs.Commons

Rectangle {
    id: root

    property alias text: label.text
    property color textColor: Theme.foreground
    property bool active: false
    property int horizontalPadding: 8

    signal clicked
    signal rightClicked
    signal middleClicked
    signal scrolled(int delta)

    implicitWidth: label.implicitWidth + horizontalPadding * 2
    implicitHeight: Theme.barHeight

    color: mouse.containsMouse ? Theme.surface : "transparent"

    Text {
        id: label

        anchors.centerIn: parent
        color: root.active ? Theme.accent : root.textColor
        font.family: Theme.fontFamily
        font.pointSize: Theme.fontSize
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: function (event) {
            if (event.button === Qt.RightButton) {
                root.rightClicked();
            } else if (event.button === Qt.MiddleButton) {
                root.middleClicked();
            } else {
                root.clicked();
            }
        }

        onWheel: function (event) { root.scrolled(event.angleDelta.y); }
    }
}
