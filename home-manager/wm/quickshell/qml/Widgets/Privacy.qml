// Privacy indicators: something is capturing audio, or something is capturing
// the screen. Shown only while it is happening — an always-visible privacy icon
// tells you nothing.
//
// There is no Quickshell service for this, so it is inferred from PipeWire's
// stream classes, the same way waybar's privacy module does it:
//   Stream/Input/Audio -> a microphone is being recorded
//   Stream/Input/Video -> a screencast or camera is being captured
// Verified against a live `pw-record`, which appears exactly as
// isStream + Stream/Input/Audio.
//
// The mic glyph here is not redundant with the Microphone widget: that one shows
// the *device* state (muted or not), this one shows that something is actually
// listening.
import QtQuick
import Quickshell.Services.Pipewire

import qs.Commons
import qs.Ui

Row {
    id: root

    // Matched on media.class alone: `isStream` is audio-specific in Quickshell and
    // reads false for a video stream, so requiring it hid screen sharing entirely.
    // Verified while chromium was receiving a Hyprland screencast.
    function streamsOfClass(mediaClass) {
        return (Pipewire.nodes?.values ?? []).filter(n => {
            return n.properties && n.properties["media.class"] === mediaClass;
        });
    }

    readonly property var audioCaptures: streamsOfClass("Stream/Input/Audio")
    readonly property var videoCaptures: streamsOfClass("Stream/Input/Video")

    // `properties` is only populated for tracked nodes, so the scan needs them
    // all held open rather than just the ones already matched.
    PwObjectTracker {
        objects: Pipewire.nodes?.values ?? []
    }

    spacing: Theme.widgetGap

    BarButton {
        visible: root.videoCaptures.length > 0
        // md-monitor_share (U+F1483). Glyph codepoints are verified against the
        // font before use: the first pick here was md-numeric_5_box_outline,
        // which rendered the privacy indicator as a literal "5".
        text: "\udb85\udc83"
        textColor: Theme.urgent
    }

    BarButton {
        visible: root.audioCaptures.length > 0
        // Microphone being listened to.
        text: "\uf130"
        textColor: Theme.urgent
    }
}
