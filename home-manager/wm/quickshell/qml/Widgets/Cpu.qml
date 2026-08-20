// CPU usage, sampled from /proc/stat.
//
// Usage is a *rate*, so it needs two samples: the jiffy counters are cumulative
// since boot, and the difference between ticks is the only thing that means
// anything. A first reading on its own is the average since boot, which is not
// what anyone reads a bar widget for.
//
// FileView reads /proc directly, so unlike waybar (which shelled out every 2s)
// and Omarchy (which runs awk on a timer) this costs no process spawn.
import QtQuick
import Quickshell.Io

import qs.Ui

BarButton {
    id: root

    readonly property int interval: 2000

    property int usage: 0
    property real lastIdle: -1
    property real lastTotal: -1

    function sample() {
        const line = stat.text().split("\n")[0];
        if (!line.startsWith("cpu ")) return;

        // cpu user nice system idle iowait irq softirq steal ...
        const fields = line.split(/\s+/).slice(1).filter(f => f.length > 0).map(Number);
        if (fields.length < 5) return;

        const idle = fields[3] + fields[4];
        const total = fields.reduce((sum, v) => sum + v, 0);

        if (lastTotal >= 0) {
            const dTotal = total - lastTotal;
            const dIdle = idle - lastIdle;
            if (dTotal > 0) usage = Math.round(Math.max(0, Math.min(100, (1 - dIdle / dTotal) * 100)));
        }

        lastIdle = idle;
        lastTotal = total;
    }

    text: usage + "%"

    onClicked: activity.running = true

    FileView {
        id: stat

        path: "/proc/stat"
        preload: true
    }

    Timer {
        running: true
        interval: root.interval
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            stat.reload();
            root.sample();
        }
    }

    Process {
        id: activity

        command: ["ghostty", "--class=terminal.float", "-e", "btop"]
    }
}
