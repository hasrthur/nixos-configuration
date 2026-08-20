// Default source (microphone) state. Same gestures as the sink widget: left click
// picks the device, right click mutes, scroll adjusts.
//
// Only shown while the mic is muted or in use, so a machine that never records
// does not carry a permanently dead glyph. Glyphs are \u escapes because literal
// private-use codepoints do not survive every editing path.
import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

import qs.Commons
import qs.Ui

BarButton {
    id: root

    // PipeWire does not always have a default source set — this machine has two
    // inputs and no default among them — so fall back to the preferred one, then
    // to any audio node that is neither a sink nor a stream.
    readonly property var source: Pipewire.defaultAudioSource
                                  ?? Pipewire.preferredDefaultAudioSource
                                  ?? firstInput

    readonly property var firstInput: {
        const nodes = Pipewire.nodes?.values ?? [];
        for (const node of nodes) {
            if (node.audio && !node.isSink && !node.isStream) return node;
        }
        return null;
    }
    readonly property real volume: source?.audio?.volume ?? 0
    readonly property bool muted: source?.audio?.muted ?? false

    function setVolume(value) {
        if (!source?.audio) return;
        source.audio.muted = false;
        source.audio.volume = Math.max(0, Math.min(1, value));
    }

    visible: source !== null
    text: muted ? "\uf131" : "\uf130 " + Math.round(volume * 100) + "%"
    // Red while live, not while muted: an open mic is the condition worth
    // noticing. Same rule as waybar's `#pulseaudio.mic:not(.source-muted)`.
    textColor: muted ? Theme.muted : Theme.urgent

    onClicked: picker.running = true
    onRightClicked: if (source?.audio) source.audio.muted = !source.audio.muted
    onScrolled: delta => root.setVolume(root.volume + (delta > 0 ? 0.05 : -0.05))

    // Tracking every node keeps `audio` populated, which the fallback scan needs
    // in order to tell an input apart from a sink.
    PwObjectTracker {
        objects: Pipewire.nodes?.values ?? []
    }

    Process {
        id: picker

        command: ["pwmenu", "-l", "rofi", "-m", "input-devices"]
    }
}
