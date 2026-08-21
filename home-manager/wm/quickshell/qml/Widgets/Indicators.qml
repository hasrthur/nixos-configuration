// The indicators cluster: status glyphs for modes that are on.
//
// Slots are reserved whether or not their mode is active, so turning one on never
// shifts the cluster's neighbours. Omarchy's order is Dictation, ScreenRecording,
// Reminder, NightLight, Dnd, StayAwake; ours holds only the one that exists, and
// the rest slot in as Track B builds those toggles.
//
// Omarchy also reveals inactive indicators at 45% on hover. Pointless with a
// single member, so not carried over yet.
import QtQuick

import qs.Commons
import qs.Ui

Row {
    // Padding-driven, as everywhere else on this bar.
    spacing: 0

    BarIndicator {
        // md-bell_off, as Omarchy uses.
        text: "\udb80\udc9b"
        active: Toggles.dnd

        onToggled: Toggles.toggleDnd()
    }
}
