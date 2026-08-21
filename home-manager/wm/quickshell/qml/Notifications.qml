// Notification popups.
//
// The tracked list *is* the popup list: each card runs its own timer and calls
// dismiss() when it fires, which drops the notification from
// server.trackedNotifications and so from the view. Critical notifications get no
// timer at all — the spec's point is that they wait for a person.
//
// Durations follow Omarchy: an app's requested expireTimeout is honoured but
// clamped, so nothing flashes past unreadably and nothing camps on screen either.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland

import qs.Commons

PanelWindow {
    id: root

    readonly property int lowDuration: 5000
    readonly property int normalDuration: 8000
    readonly property int maxDuration: 30000

    function durationFor(notification) {
        if (notification.urgency === NotificationUrgency.Critical) return 0;

        const floor = notification.urgency === NotificationUrgency.Low
            ? root.lowDuration : root.normalDuration;
        // expireTimeout is in milliseconds, and <= 0 means "you decide".
        const requested = Number(notification.expireTimeout) || 0;
        return Math.min(root.maxDuration, Math.max(floor, requested));
    }

    // The spec reserves the "default" action for "the user clicked the
    // notification itself", and says implementations need not display it. Drawing
    // it anyway produced an unlabelled bordered box that reads as a stray
    // checkbox — which is what Claude Code's notification looked like.
    function buttonActions(notification) {
        return (notification.actions ?? []).filter(a => {
            return a.identifier !== "default" && String(a.text ?? "") !== "";
        });
    }

    function defaultAction(notification) {
        for (const a of notification.actions ?? []) {
            if (a.identifier === "default") return a;
        }
        return null;
    }

    function dismissLast() {
        const list = server.trackedNotifications?.values ?? [];
        if (list.length > 0) list[list.length - 1].dismiss();
    }

    function dismissAll() {
        // Copy first: dismissing mutates the model being walked.
        const list = (server.trackedNotifications?.values ?? []).slice();
        for (const n of list) n.dismiss();
    }

    screen: {
        const target = Hyprland.focusedMonitor?.name ?? "";
        for (const s of Quickshell.screens) {
            if (s.name === target) return s;
        }
        return Quickshell.screens[0] ?? null;
    }

    anchors.top: true
    anchors.right: true
    margins.top: Theme.barHeight + Theme.menuGap
    margins.right: Theme.menuGap
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    // Cards carry buttons, so they need clicks — but not the keyboard, which
    // would steal focus from whatever the notification is about.
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    implicitWidth: Theme.notificationWidth
    implicitHeight: Math.max(1, stack.implicitHeight)
    color: "transparent"
    visible: (server.trackedNotifications?.values ?? []).length > 0

    NotificationServer {
        id: server

        // Without this the Notification object is destroyed the moment the
        // signal handler returns, so trackedNotifications stays empty and nothing
        // is ever drawn. Tracking is the opt-in that keeps it alive; the card's
        // own dismiss() is what releases it again.
        onNotification: function (notification) {
            notification.tracked = true;
        }

        keepOnReload: false
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
    }

    // Reachable as `wm-shell notifications dismissLast` / `dismissAll`.
    IpcHandler {
        target: "notifications"

        function dismissLast(): string {
            root.dismissLast();
            return "ok";
        }

        function dismissAll(): string {
            root.dismissAll();
            return "ok";
        }
    }

    Column {
        id: stack

        width: parent.width
        spacing: Theme.menuGap

        Repeater {
            model: server.trackedNotifications

            Rectangle {
                id: card

                required property var modelData

                readonly property bool critical: modelData.urgency === NotificationUrgency.Critical

                width: stack.width
                implicitHeight: content.implicitHeight + Theme.menuPadding * 2
                height: implicitHeight
                color: Theme.menuBackground
                radius: Theme.menuRadius
                border.width: Theme.menuBorderWidth
                // Critical is the one case worth colouring: it is also the one
                // case that will not go away on its own.
                border.color: card.critical ? Theme.urgent : Theme.menuBorder

                Timer {
                    running: !card.critical
                    interval: Math.max(1, root.durationFor(card.modelData))

                    onTriggered: card.modelData.dismiss()
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    // Left click runs the default action where the app offered
                    // one; anything else just dismisses.
                    onClicked: function (event) {
                        const fallback = root.defaultAction(card.modelData);
                        if (event.button === Qt.LeftButton && fallback) {
                            fallback.invoke();
                        } else {
                            card.modelData.dismiss();
                        }
                    }
                }

                Column {
                    id: content

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.menuPadding
                    spacing: 4

                    Text {
                        width: parent.width
                        visible: text !== ""
                        text: card.modelData.appName ?? ""
                        color: card.critical ? Theme.urgent : Theme.muted
                        elide: Text.ElideRight
                        font.family: Theme.fontFamily
                        font.pointSize: Theme.fontSize - 2
                    }

                    Text {
                        width: parent.width
                        visible: text !== ""
                        text: card.modelData.summary ?? ""
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
                        text: card.modelData.body ?? ""
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
                        visible: root.buttonActions(card.modelData).length > 0
                        topPadding: 4

                        Repeater {
                            model: root.buttonActions(card.modelData)

                            Rectangle {
                                required property var modelData

                                implicitWidth: actionLabel.implicitWidth + Theme.menuPadding * 2
                                implicitHeight: Math.round(Theme.fontSize * 2)
                                radius: Math.max(2, Theme.menuRadius - 2)
                                color: actionHover.containsMouse ? Theme.menuHighlight : "transparent"
                                border.width: 1
                                border.color: Theme.menuBorder

                                Text {
                                    id: actionLabel

                                    anchors.centerIn: parent
                                    text: parent.modelData.text ?? ""
                                    color: Theme.foreground
                                    font.family: Theme.fontFamily
                                    font.pointSize: Theme.fontSize - 1
                                }

                                MouseArea {
                                    id: actionHover

                                    anchors.fill: parent
                                    hoverEnabled: true

                                    onClicked: parent.modelData.invoke()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
