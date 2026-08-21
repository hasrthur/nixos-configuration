// Shared, persisted desktop toggles.
//
// A singleton because the state has two readers in different object trees: the
// notification window decides whether to show a popup, and the bar's indicator
// draws whether it is on. Passing a reference between them would mean threading
// it through the bar, which is how Omarchy ends up needing a service registry.
//
// Persisted because a toggle that silently resets on restart fails in the worst
// direction — you would believe you were still silenced.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool dnd: false

    function setDnd(value) {
        if (root.dnd === value) return;
        root.dnd = value;
        root.persist();
    }

    function toggleDnd() {
        root.setDnd(!root.dnd);
    }

    function persist() {
        state.dnd = root.dnd;
        stateFile.writeAdapter();
    }

    FileView {
        id: stateFile

        path: Theme.stateDir + "/toggles.json"
        // The shell is the only writer; watching would only race with itself.
        watchChanges: false
        printErrors: false

        // Adopt whatever was on disk once it has loaded, without writing back.
        onLoaded: root.dnd = state.dnd

        JsonAdapter {
            id: state

            property bool dnd: false
        }
    }
}
