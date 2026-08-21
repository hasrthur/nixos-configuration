// Notification popups, plus a replayable history.
//
// Live notifications come from the server's tracked set; each card runs its own
// timer and dismisses itself, which drops it from that set. Critical ones get no
// timer — the point of the urgency is that it waits for a person.
//
// History is written on arrival rather than on departure, which also captures
// notifications silenced before they were ever seen — the exact thing "what did I
// miss" wants. It is capped, persisted as JSON, and replayed as fresh cards
// rather than shown in a panel: Omarchy has no notification centre and neither
// does this.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland

import qs.Commons
import qs.Ui

PanelWindow {
    id: root

    readonly property int lowDuration: 5000
    readonly property int normalDuration: 8000
    readonly property int maxDuration: 30000
    readonly property int historyLimit: 10
    // Long enough to read a stack of ten and click one. A replay is a deliberate
    // act, not an interruption, so it does not need to get out of the way fast.
    readonly property int replayDuration: 20000


    // Replayed history entries, shown as cards until their own timer expires.
    property var replayed: []

    function durationFor(notification) {
        if (notification.urgency === NotificationUrgency.Critical) return 0;

        const floor = notification.urgency === NotificationUrgency.Low
            ? root.lowDuration : root.normalDuration;
        const requested = Number(notification.expireTimeout) || 0;
        return Math.min(root.maxDuration, Math.max(floor, requested));
    }

    // Omarchy lets a narrow set through: user-action confirmations and critical
    // alerts from notify-send. Chat apps set their own appName and fall outside it.
    function bypassesSilence(notification) {
        return notification.urgency === NotificationUrgency.Critical
            && (notification.appName ?? "") === "notify-send";
    }

    // The spec reserves "default" for "the user clicked the notification itself"
    // and says implementations need not draw it. Drawing it produced an
    // unlabelled box that read as a stray checkbox.
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

    function record(notification) {
        const entry = {
            appName: notification.appName ?? "",
            summary: notification.summary ?? "",
            body: notification.body ?? "",
            critical: notification.urgency === NotificationUrgency.Critical,
            // Kept so a replayed card can still jump to the sender. Its actions
            // cannot be replayed — the process that owned them has moved on — but
            // the window it belongs to is usually still there.
            target: root.focusTarget(notification),
            icon: root.iconFor(notification)
        };

        // Newest first, so a cap trims the oldest.
        const kept = [entry].concat(history.entries ?? []).slice(0, root.historyLimit);
        history.entries = kept;
        historyFile.writeAdapter();
    }

    function showHistory() {
        const entries = (history.entries ?? []).slice();
        if (entries.length === 0) return;

        // Oldest at the top, so the stack reads in the order things happened.
        root.replayed = entries.slice().reverse().map((e, i) => ({
            key: "replay-" + Date.now() + "-" + i,
            appName: e.appName ?? "",
            summary: e.summary ?? "",
            body: e.body ?? "",
            critical: false,
            // Absent on entries recorded before these were stored.
            target: e.target ?? "",
            icon: e.icon ?? ""
        }));
        replayTimer.restart();
    }

    function clearHistory() {
        history.entries = [];
        historyFile.writeAdapter();
        root.replayed = [];
    }

    function dismissLast() {
        const list = server.trackedNotifications?.values ?? [];
        if (list.length > 0) list[list.length - 1].dismiss();
    }

    function dismissAll() {
        // Copy first: dismissing mutates the model being walked.
        const list = (server.trackedNotifications?.values ?? []).slice();
        for (const n of list) n.dismiss();
        root.replayed = [];
    }

    // Clicking a notification should take you to whatever sent it.
    //
    // Both halves are needed, not one or the other. Apps that register a
    // "default" action expect it invoked; but a sender running *inside* another
    // app's window — Claude Code in a terminal — registers one whose handler
    // cannot raise a window it does not own, so invoking alone leaves the click
    // doing nothing. Focusing as well is harmless for apps that raise themselves.
    //
    // desktopEntry is the reliable identifier and appName is not: Claude Code
    // sends appName="" with desktopEntry="com.mitchellh.ghostty", while
    // notify-send sends appName="notify-send" and no desktop entry.
    function focusTarget(notification) {
        const entry = String(notification.desktopEntry ?? "");
        if (entry !== "") return entry;
        return String(notification.appName ?? "");
    }

    // image is the notification's own picture; appIcon is the sending app's.
    function iconFor(notification) {
        const image = String(notification.image ?? "");
        if (image !== "") return image;
        return String(notification.appIcon ?? "");
    }

    function focusByName(target) {
        if (String(target ?? "") === "") return;
        focusApp.command = ["wm-hyprland-focus-app", String(target)];
        focusApp.running = true;
    }

    function activate(notification) {
        const action = root.defaultAction(notification);
        if (action) action.invoke();

        root.focusByName(root.focusTarget(notification));
        notification.dismiss();
    }

    // Omarchy's invokeLast acts on the newest popup and does nothing when the
    // screen is clear, which reads as a dead key. Falling back to the newest
    // history entry keeps the gesture meaning "take me to the last thing that
    // wanted me", whether or not its toast is still up.
    function invokeLast() {
        const list = server.trackedNotifications?.values ?? [];
        if (list.length > 0) {
            root.activate(list[list.length - 1]);
            return;
        }

        const recent = (history.entries ?? [])[0];
        if (recent) root.focusByName(recent.target);
    }

    readonly property var shown: {
        const list = server.trackedNotifications?.values ?? [];
        if (!Toggles.dnd) return list;
        return list.filter(n => root.bypassesSilence(n));
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
    visible: shown.length > 0 || replayed.length > 0

    NotificationServer {
        id: server

        // Without this the Notification object is destroyed the moment the
        // handler returns, so trackedNotifications stays empty and nothing draws.
        onNotification: function (notification) {
            notification.tracked = true;
            root.record(notification);
        }

        keepOnReload: false
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
    }

    FileView {
        id: historyFile

        path: Theme.stateDir + "/notifications.json"
        // The shell is the only writer; watching would only race with itself.
        watchChanges: false
        printErrors: false

        JsonAdapter {
            id: history

            property var entries: []
        }
    }

    Process {
        id: focusApp

        running: false
    }

    Timer {
        id: replayTimer

        interval: root.replayDuration

        onTriggered: root.replayed = []
    }

    // Reachable as `wm-shell notifications <method>`.
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

        function invokeLast(): string {
            root.invokeLast();
            return "ok";
        }

        // Silencing hides the popup, not the notification: it stays tracked, so
        // dismissAll and invokeLast still reach it, and it appears when silence
        // lifts. State lives in qs.Commons.Toggles so the bar indicator sees it
        // too, and so it survives a restart.
        function toggleSilence(): string {
            Toggles.toggleDnd();
            return Toggles.dnd ? "silenced" : "audible";
        }

        function dndState(): string {
            return Toggles.dnd ? "on" : "off";
        }

        function setDnd(value: string): string {
            const on = value === "on" || value === "true" || value === "1";
            const off = value === "off" || value === "false" || value === "0";
            if (!on && !off) return "usage: setDnd <on|off>";

            Toggles.setDnd(on);
            return Toggles.dnd ? "on" : "off";
        }

        // Lets a script supersede its own earlier toast.
        function dismiss(summary: string): string {
            const list = (server.trackedNotifications?.values ?? []).slice();
            let hits = 0;
            for (const n of list) {
                if ((n.summary ?? "") === summary) {
                    n.dismiss();
                    hits++;
                }
            }
            return String(hits);
        }

        function ping(): string {
            return "ok";
        }

        function showHistory(): string {
            root.showHistory();
            return String((history.entries ?? []).length);
        }

        function clearHistory(): string {
            root.clearHistory();
            return "ok";
        }
    }

    Column {
        id: stack

        width: parent.width
        spacing: Theme.menuGap

        Repeater {
            model: root.replayed

            NotificationCard {
                required property var modelData

                width: stack.width
                appName: modelData.appName
                summary: modelData.summary
                body: modelData.body
                critical: modelData.critical
                iconSource: modelData.icon ?? ""
                replayed: true

                onDismissRequested: root.replayed = []
                // A record is still worth clicking: jump to whatever sent it.
                onDefaultRequested: {
                    root.focusByName(modelData.target);
                    root.replayed = [];
                }
            }
        }

        Repeater {
            model: root.shown

            NotificationCard {
                id: card

                required property var modelData

                width: stack.width
                appName: card.modelData.appName ?? ""
                summary: card.modelData.summary ?? ""
                body: card.modelData.body ?? ""
                critical: card.modelData.urgency === NotificationUrgency.Critical
                actionModel: root.buttonActions(card.modelData)
                iconSource: root.iconFor(card.modelData)

                onDismissRequested: card.modelData.dismiss()
                onDefaultRequested: root.activate(card.modelData)

                Timer {
                    running: !card.critical
                    interval: Math.max(1, root.durationFor(card.modelData))

                    onTriggered: card.modelData.dismiss()
                }
            }
        }
    }
}
