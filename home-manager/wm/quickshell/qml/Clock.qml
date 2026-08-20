// Same format the waybar clock used, so the swap is not also a change of habit.
import QtQuick
import Quickshell

import qs.Commons

Text {
    color: Theme.foreground
    font.family: Theme.fontFamily
    font.pointSize: Theme.fontSize
    text: Qt.formatDateTime(clock.date, "ddd d MMM HH:mm")

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }
}
