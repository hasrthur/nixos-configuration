// One indicator in the bar's cluster.
//
// Numbers and behaviour follow Omarchy's Ui/BarIndicator: a fixed slot width so
// the slot is reserved whether or not the mode is on, 5px margins, and caption-
// sized text — indicators are meant to read smaller than the bar's own widgets.
//
// The slot is the important part. Omarchy keeps space (`keepSpace: true`) and
// hides an inactive indicator by dropping its opacity to zero rather than
// collapsing it, so a mode turning on never reflows its neighbours. Collapsing
// the item instead is what made the clock jump.
//
// No special colour, as theirs: `useActiveColor: false`. Presence is the signal,
// and a permanently amber glyph shouts louder than anything Omarchy does.
import QtQuick

import qs.Commons

Item {
    id: root

    property bool active: false
    property string text: ""

    signal toggled

    implicitWidth: Theme.indicatorSlot
    implicitHeight: Theme.barHeight

    Text {
        anchors.centerIn: parent
        text: root.text
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pointSize: Theme.indicatorFontSize
        // Reserved, not removed: opacity keeps the slot while hiding the glyph.
        opacity: root.active ? 1 : 0
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.active

        onClicked: root.toggled()
    }
}
