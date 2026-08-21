// The menu: one searchable tree covering apps, actions and toggles.
//
// This is what replaces rofi as a launcher. Omarchy took the same route — v4
// uninstalls walker and its whole elephant-* provider set, and answers
// Super+Space with its own menu instead. Having one tree rather than a launcher
// plus separate menus is what makes a single key sufficient for most things.
//
// The tree is data, generated from menu.nix into qs.Commons.MenuTree, so it
// survives a rewrite of this file. Dotted ids imply hierarchy; `provider` rows
// are filled by the shell at runtime; `action` rows run a command.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

import qs.Commons

PanelWindow {
    id: root

    // Route stack; empty means the root menu.
    property var stack: []
    property string filter: ""
    property int highlighted: 0

    readonly property string route: stack.length > 0 ? stack[stack.length - 1] : ""

    // Declaration order for the search tiebreak. builtins.toJSON sorts the
    // attrset, so this is menu.nix's ids alphabetically — stable across builds,
    // which is what the tiebreak needs it to be.
    readonly property var routeIds: Object.keys(MenuTree.routes)

    readonly property int rowsHeight: Math.min(rows.length, Theme.launcherMaxRows) * Theme.launcherRowHeight
                                      + Theme.menuPadding

    function segments(id) {
        return id.split(".");
    }

    // Children of the current route: one segment deeper, same prefix.
    function childrenOf(route) {
        const depth = route === "" ? 1 : root.segments(route).length + 1;
        const prefix = route === "" ? "" : route + ".";
        const out = [];

        for (const id in MenuTree.routes) {
            if (!id.startsWith(prefix)) continue;
            if (root.segments(id).length !== depth) continue;

            const entry = MenuTree.routes[id];
            out.push({
                id: id,
                icon: entry.icon ?? "",
                label: entry.label ?? id,
                action: entry.action ?? "",
                provider: entry.provider ?? "",
                app: null
            });
        }
        return out;
    }

    // A desktop entry's icon is a themed name, an absolute path, or already a
    // URL. Omarchy additionally builds an index of app/device icons, because an
    // unconstrained themed lookup can resolve a name like "zoom" to an action
    // icon; that refinement is not carried over yet.
    function iconSource(icon) {
        const value = String(icon ?? "");
        if (value === "") return Quickshell.iconPath("application-x-executable", true);
        if (value.startsWith("file://") || value.startsWith("image://")) return value;
        if (value.startsWith("/")) return "file://" + value;
        return Quickshell.iconPath(value, true);
    }

    // Ids whose winning desktop file is hidden. DesktopEntries yields an entry
    // per file without deduplicating by id, so a NoDisplay override in an earlier
    // XDG directory does not shadow the package's own visible copy — both arrive,
    // and filtering on `noDisplay` alone keeps the visible one. The scan resolves
    // precedence properly; Omarchy needs the same helper for the same reason.
    property var hiddenIds: ({})

    function appRows() {
        const out = [];
        for (const entry of DesktopEntries.applications?.values ?? []) {
            if (entry.noDisplay) continue;
            if (root.hiddenIds[entry.id] === true) continue;
            // A generic name and the desktop Keywords are searchable but never
            // shown, which is how "browser" finds Firefox. Omarchy folds both
            // into the aliases of the app row for the same reason.
            const aliases = entry.genericName ? [entry.genericName] : [];
            out.push({
                id: "app:" + entry.name,
                icon: entry.icon ?? "",
                label: entry.name,
                action: "",
                provider: "",
                app: entry,
                aliases: aliases.concat(entry.keywords ?? []),
                description: entry.genericName ?? "",
                // Apps hang off the apps route, so they sit one level below it.
                depth: 2,
                order: out.length
            });
        }
        out.sort((a, b) => a.label.localeCompare(b.label));
        return out;
    }

    // Search ranking, ported from Omarchy's MenuModel.js.
    //
    // Not fuzzy, deliberately: a term has to appear as a substring of the row's
    // name text or as a whole word in its description, and ranking is fixed
    // tiers broken by depth and then declaration order. Nothing is learned from
    // use. Walker, which Omarchy dropped, had both a subsequence matcher and
    // frecency; a curated tree is worth more than either here, because
    // Super+Space, n, Enter has to land on the same row every time.
    function searchableToken(value) {
        return String(value ?? "").replace(/[._-]+/g, " ");
    }

    // Everything a term may match as a substring: the label, the last id segment
    // (so "generations" finds nix.generations even though its label does not say
    // it), and an app's generic name and keywords.
    function nameSearchText(row) {
        const leaf = root.segments(row.id).pop() ?? "";
        return [row.label, root.searchableToken(leaf), (row.aliases ?? []).join(" ")]
            .join(" ").toLowerCase();
    }

    function termInWords(term, text) {
        return String(text ?? "").toLowerCase().split(/\s+/).indexOf(term) >= 0;
    }

    // A description matches by whole word only. It is prose, so a substring hit
    // would put half the tree behind any common run of letters.
    function descriptionMatches(needle, text) {
        return needle.split(/\s+/).every(term => term === "" || root.termInWords(term, text));
    }

    function matchesQuery(row, terms) {
        const nameText = root.nameSearchText(row);
        const description = String(row.description ?? "").toLowerCase();
        return terms.every(term => nameText.indexOf(term) >= 0
                                   || root.termInWords(term, description));
    }

    // Lower is better, as in Omarchy: the tier is multiplied out so depth and
    // order can only ever break a tie inside one.
    function searchScore(row, needle) {
        const label = row.label.toLowerCase();
        const nameText = root.nameSearchText(row);
        const description = String(row.description ?? "").toLowerCase();
        const isApp = row.app !== null;
        const isMenu = !isApp && row.action === "" && row.provider === "";

        let score = 80;
        if (label === needle)
            score = row.depth === 1 ? 2 : 0;
        // An installed app whose name carries the query as a whole word — "code"
        // for Visual Studio Code — beats a menu row labelled exactly that.
        else if (isApp && label.split(/\s+/).indexOf(needle) >= 0)
            score = 0;
        else if (label.indexOf(needle) === 0)
            score = 10;
        else if (label.indexOf(needle) >= 0)
            score = 30;
        else if (nameText.indexOf(needle) >= 0)
            score = 40;
        else if (root.descriptionMatches(needle, description))
            score = 60;

        // A submenu is a step towards something rather than the thing, so an
        // equal match on one loses to a row that acts.
        if (isMenu) score -= 2;
        // App rows are appended after every menu row, so they lose the order
        // tiebreak on an equal match. Outrank that, but stay inside the tier.
        if (isApp) score -= 5;

        return score * 1000 + row.depth * 25 + row.order;
    }

    // Searching looks across everything, not just the current level: typing is
    // how you avoid navigating at all, so scoping it to one submenu would make
    // the tree the only way through. Submenus are results too — selecting one
    // opens it, which is how a search can end somewhere it cannot act.
    function searchRows(text) {
        const needle = text.toLowerCase().trim();
        const terms = needle.split(/\s+/).filter(term => term !== "");
        const out = [];

        for (let i = 0; i < root.routeIds.length; i++) {
            const id = root.routeIds[i];
            const entry = MenuTree.routes[id];
            const row = {
                id: id,
                icon: entry.icon ?? "",
                label: entry.label ?? id,
                detail: root.segments(id).slice(0, -1).join(" / "),
                action: entry.action ?? "",
                provider: entry.provider ?? "",
                app: null,
                aliases: [],
                description: entry.description ?? "",
                depth: root.segments(id).length,
                order: i
            };
            if (root.matchesQuery(row, terms)) out.push(row);
        }

        for (const row of root.appRows()) {
            if (root.matchesQuery(row, terms)) out.push(row);
        }

        for (const row of out) row.score = root.searchScore(row, needle);
        out.sort((a, b) => a.score - b.score);
        return out;
    }

    readonly property var rows: {
        if (filter !== "") return root.searchRows(filter);
        if (MenuTree.routes[route]?.provider === "apps") return root.appRows();
        return root.childrenOf(route);
    }

    function activate(index) {
        const row = rows[index];
        if (!row) return;

        if (row.app) {
            // Terminal=true entries (btop, and most TUIs) have no window of their
            // own: execute() launches them into nowhere and nothing appears. They
            // need a terminal, and a floating one, via the existing window rule.
            if (row.app.runInTerminal) {
                runner.command = ["ghostty", "--class=terminal.float", "-e",
                                  "sh", "-c", row.app.execString];
                runner.running = true;
            } else {
                row.app.execute();
            }
            root.close();
            return;
        }

        if (row.provider !== "") {
            root.stack = root.stack.concat([row.id]);
            root.filter = "";
            root.highlighted = 0;
            return;
        }

        if (row.action !== "") {
            runner.command = ["sh", "-c", row.action];
            runner.running = true;
            root.close();
            return;
        }

        // No action and no provider: it is a submenu.
        root.stack = root.stack.concat([row.id]);
        root.filter = "";
        root.highlighted = 0;
    }

    function back() {
        if (filter !== "") {
            root.filter = "";
            root.highlighted = 0;
            return;
        }
        if (stack.length === 0) {
            root.close();
            return;
        }
        root.stack = root.stack.slice(0, -1);
        root.highlighted = 0;
    }

    function open(route) {
        root.stack = route && route !== "root" && MenuTree.routes[route] ? [route] : [];
        root.filter = "";
        root.highlighted = 0;
        root.visible = true;
    }

    function close() {
        root.visible = false;
    }

    screen: {
        const target = Hyprland.focusedMonitor?.name ?? "";
        for (const s of Quickshell.screens) {
            if (s.name === target) return s;
        }
        return Quickshell.screens[0] ?? null;
    }

    // The window covers the screen and the card sits inside it, which is how
    // Omarchy does it. Clicking "outside" then means clicking this window's own
    // backdrop, so no focus grab is involved — HyprlandFocusGrab does not
    // dismiss a layer surface holding exclusive keyboard focus, which is why the
    // tray's PopupWindow dismissed on an outside click and this did not.
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    // Its own namespace so a compositor layer rule can target the launcher
    // without also blurring the bar — every Quickshell surface shares the
    // default "quickshell" namespace otherwise.
    WlrLayershell.namespace: "wm-launcher"
    // A launcher is the one surface that must take the keyboard.
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    onVisibleChanged: if (visible) search.forceActiveFocus()

    Process {
        id: runner

        running: false
    }

    Process {
        id: hiddenScan

        command: ["wm-hidden-desktop-entries"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const map = {};
                for (const line of text.split("\n")) {
                    const id = line.trim();
                    if (id !== "") map[id] = true;
                }
                root.hiddenIds = map;
            }
        }
    }

    // Reachable as `wm-shell menu toggle [route]`.
    IpcHandler {
        target: "menu"

        function toggle(route: string): string {
            if (root.visible) root.close();
            else root.open(route);
            return root.visible ? "open" : "closed";
        }

        function open(route: string): string {
            root.open(route);
            return "open";
        }

        function close(): string {
            root.close();
            return "closed";
        }
    }

    // The backdrop: a scrim at half alpha, as Omarchy uses, which both dims the
    // desktop and makes the click-to-dismiss target obvious.
    Rectangle {
        anchors.fill: parent
        color: Theme.menuBackground
        opacity: 0.5
    }

    MouseArea {
        anchors.fill: parent

        onClicked: root.close()
    }

    Rectangle {
        id: card

        // A fixed distance from the top, not centred. Omarchy opens centred and
        // then freezes the top line on the first keystroke so it stops
        // re-centring; pinning it outright is simpler and puts the card where the
        // eye already is.
        y: Theme.launcherTopMargin
        anchors.horizontalCenter: parent.horizontalCenter
        width: Theme.launcherWidth
        height: implicitHeight
        implicitHeight: header.height + list.height + Theme.menuBorderWidth * 2
        color: Theme.menuBackground
        radius: Theme.menuRadius
        border.width: Theme.menuBorderWidth
        border.color: Theme.menuBorder

        MouseArea {
            anchors.fill: parent
            // Swallow clicks so they do not fall through to the backdrop and
            // close the very menu being used.
            onClicked: {}
        }

        Item {
            id: header

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.menuBorderWidth
            height: Theme.launcherRowHeight + Theme.menuPadding

            Text {
                id: crumb

                anchors.left: parent.left
                anchors.leftMargin: Theme.menuPadding
                anchors.verticalCenter: parent.verticalCenter
                text: root.stack.length > 0
                    ? (MenuTree.routes[root.route]?.label ?? root.route) + "  ›"
                    : "›"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pointSize: Theme.fontSize
            }

            TextInput {
                id: search

                anchors.left: crumb.right
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: Theme.menuPadding
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.emphasis
                font.family: Theme.fontFamily
                font.pointSize: Theme.fontSize
                selectByMouse: true
                text: root.filter

                onTextChanged: {
                    root.filter = text;
                    root.highlighted = 0;
                }

                Keys.onDownPressed: root.highlighted = Math.min(root.rows.length - 1, root.highlighted + 1)
                Keys.onUpPressed: root.highlighted = Math.max(0, root.highlighted - 1)
                Keys.onReturnPressed: root.activate(root.highlighted)
                Keys.onEnterPressed: root.activate(root.highlighted)
                Keys.onEscapePressed: root.back()
                // Left only navigates when the field is empty, or it would fight
                // ordinary text editing.
                Keys.onLeftPressed: function (event) {
                    if (text === "") root.back();
                    else event.accepted = false;
                }
                Keys.onTabPressed: root.activate(root.highlighted)
            }
        }

        ListView {
            id: list

            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.menuBorderWidth
            anchors.rightMargin: Theme.menuBorderWidth
            height: root.rowsHeight
            clip: true
            model: root.rows
            currentIndex: root.highlighted
            highlightMoveDuration: 80
            // Keep the highlighted row on screen when navigating by keyboard.
            highlightRangeMode: ListView.ApplyRange
            preferredHighlightBegin: Theme.launcherRowHeight
            preferredHighlightEnd: height - Theme.launcherRowHeight

            delegate: Item {
                id: row

                required property var modelData
                required property int index

                width: list.width
                height: Theme.launcherRowHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.menuPadding / 2
                    anchors.rightMargin: Theme.menuPadding / 2
                    anchors.topMargin: 1
                    anchors.bottomMargin: 1
                    visible: root.highlighted === row.index
                    radius: Math.max(2, Theme.menuRadius - 2)
                    color: Theme.menuHighlight
                }

                Item {
                    id: rowIcon

                    anchors.left: parent.left
                    anchors.leftMargin: Theme.menuPadding
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.launcherIconWidth
                    height: parent.height

                    // Menu routes carry a Nerd Font glyph; apps carry an image.
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !row.modelData.app
                        text: row.modelData.icon ?? ""
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pointSize: Theme.fontSize
                    }

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !!row.modelData.app
                        width: Theme.launcherAppIconSize
                        height: Theme.launcherAppIconSize
                        fillMode: Image.PreserveAspectFit
                        // Decoded at physical pixels, as in the tray: the logical
                        // size picks a smaller file and upscales it.
                        sourceSize.width: Math.round(Theme.launcherAppIconSize * Screen.devicePixelRatio)
                        sourceSize.height: Math.round(Theme.launcherAppIconSize * Screen.devicePixelRatio)
                        source: row.modelData.app ? root.iconSource(row.modelData.app.icon) : ""
                        asynchronous: true
                    }
                }

                Text {
                    anchors.left: rowIcon.right
                    anchors.right: detail.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    text: row.modelData.label
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pointSize: Theme.fontSize
                }

                // Where a search hit lives, so two rows with the same label are
                // still tellable apart.
                Text {
                    id: detail

                    anchors.right: parent.right
                    anchors.rightMargin: Theme.menuPadding
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.detail ?? ""
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pointSize: Theme.fontSize - 2
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: root.highlighted = row.index
                    onClicked: root.activate(row.index)
                }
            }
        }
    }
}
