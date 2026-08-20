// Default sink volume. Left click opens the device picker, right click mutes,
// scroll adjusts — the same gestures the waybar module had.
//
// The picker is pwmenu for now; it goes away when the audio panel lands.
import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

import qs.Commons
import qs.Ui

BarButton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? true

    // Nerd Font speaker ramp: off, low, high.
    readonly property string glyph: {
        if (muted) return "";
        if (volume < 0.34) return "";
        if (volume < 0.67) return "";
        return "";
    }

    function setVolume(value) {
        if (!sink?.audio) return;
        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    visible: sink !== null
    text: muted ? glyph : glyph + " " + Math.round(volume * 100) + "%"
    textColor: muted ? Theme.muted : Theme.foreground

    onClicked: picker.running = true
    onRightClicked: if (sink?.audio) sink.audio.muted = !sink.audio.muted
    onScrolled: delta => root.setVolume(root.volume + (delta > 0 ? 0.05 : -0.05))

    // Keeps the sink's audio properties live rather than bound-but-stale.
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    Process {
        id: picker

        command: ["pwmenu", "-l", "rofi", "-m", "output-devices"]
    }
}
