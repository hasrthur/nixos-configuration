// Volume OSD.
//
// Nothing tells it to appear: it watches PipeWire and reacts, the same way the
// bar widgets read their own state. So `wm-audio-output-volume` stays a plain
// setter and anything else that moves the volume — a widget scroll, `wpctl`,
// another app — raises the OSD too.
//
// Watching alone is not enough, though: pressing volume-up at 100% changes
// nothing, so there is no state change to notice and the keypress would go
// unacknowledged. `wm-shell osd show` is the way to say "I acted" regardless of
// whether anything moved. Brightness and toggles will lean on the same entry
// point, having no property to observe at all.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland

import qs.Commons

PanelWindow {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    // Only react once the initial state has settled, or the shell flashes an OSD
    // at every launch as the bindings first evaluate.
    property bool primed: false
    property real lastVolume: -1
    property bool lastMuted: false

    function reveal() {
        lastVolume = volume;
        lastMuted = muted;
        hideTimer.restart();
        showing = true;
    }

    function report() {
        if (!sink?.audio) return;
        if (!primed) return;
        if (volume === lastVolume && muted === lastMuted) return;

        reveal();
    }

    property bool showing: false

    onVolumeChanged: report()
    onMutedChanged: report()

    // Follow the focused output, as the swayosd bindings used to. Hyprland's
    // monitors and Quickshell's screens are different objects, matched by name.
    screen: {
        const target = Hyprland.focusedMonitor?.name ?? "";
        for (const s of Quickshell.screens) {
            if (s.name === target) return s;
        }
        return Quickshell.screens[0] ?? null;
    }

    // Anchored to one edge only, so the compositor centres it on that edge.
    anchors.bottom: true
    margins.bottom: Theme.osdMargin
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight
    color: "transparent"
    visible: showing || card.opacity > 0

    // Reachable as `wm-shell osd show`.
    IpcHandler {
        target: "osd"

        function show(): string {
            root.reveal();
            return "ok";
        }
    }

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    Timer {
        id: primeTimer

        running: true
        interval: 1500

        onTriggered: {
            root.lastVolume = root.volume;
            root.lastMuted = root.muted;
            root.primed = true;
        }
    }

    Timer {
        id: hideTimer

        interval: 1200

        onTriggered: root.showing = false
    }

    Rectangle {
        id: card

        anchors.fill: parent
        implicitWidth: Theme.osdPadding * 2 + Theme.osdIconWidth + Theme.osdGap
                       + Theme.osdBarWidth + Theme.osdGap + Theme.osdReadoutWidth
        implicitHeight: Theme.osdPadding * 2 + Math.round(Theme.fontSize * 2)
        color: Theme.menuBackground
        radius: Theme.menuRadius
        border.width: Theme.menuBorderWidth
        border.color: Theme.menuBorder
        opacity: root.showing ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }

        Row {
            anchors.centerIn: parent
            spacing: Theme.osdGap

            // Fixed-width so the bar does not shift when the volume crosses an
            // icon threshold and the glyph changes width.
            Item {
                width: Theme.osdIconWidth
                height: icon.implicitHeight
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: icon

                    anchors.centerIn: parent
                    text: root.muted ? "\ueee8"
                        : root.volume < 0.34 ? "\uf026"
                        : root.volume < 0.67 ? "\uf027"
                        : "\uf028"
                    color: root.muted ? Theme.muted : Theme.foreground
                    font.family: Theme.fontFamily
                    font.pointSize: Theme.fontSize
                }
            }

            Rectangle {
                width: Theme.osdBarWidth
                height: Math.max(4, Math.round(Theme.fontSize / 3))
                anchors.verticalCenter: parent.verticalCenter
                radius: height / 2
                color: Theme.menuBorder

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, root.volume))
                    height: parent.height
                    radius: parent.radius
                    color: root.muted ? Theme.muted : Theme.accent
                }
            }

            // Also fixed-width, so the card does not resize between 9% and 100%.
            Item {
                width: Theme.osdReadoutWidth
                height: readout.implicitHeight
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: readout

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(root.volume * 100) + "%"
                    color: root.muted ? Theme.muted : Theme.foreground
                    font.family: Theme.fontFamily
                    font.pointSize: Theme.fontSize
                }
            }
        }
    }
}
