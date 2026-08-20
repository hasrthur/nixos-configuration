// A menu drawn by us, from a QsMenuHandle.
//
// QsMenuAnchor would hand the menu to Qt, and Kvantum paints its interior from
// the theme SVG on a `window.color` (base01) background — so it can never match a
// bar drawn on base00. Drawing it here also drops the QtWidgets dependency that
// platform menus needed, and gives keyboard navigation.
//
// Submenus are navigated *into* rather than opened alongside: QML refuses to
// instantiate a type inside itself even lazily, and a stack suits the keyboard
// better. Each level keeps its **own live opener**, because a child entry is
// owned by its parent opener's children model — reusing one opener destroys the
// entry currently being displayed and the submenu comes up empty.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.Commons

PopupWindow {
    id: root

    // Assigning a handle resets any submenu navigation.
    property var handle: null
    // The bar item this menu hangs off.
    property Item anchorItem: null
    // Tray items usually repeat their own name as the first entry; drop it.
    property string titleHint: ""

    // [{ opener, title }] — one per level descended into.
    property var levels: []
    property int highlighted: -1

    // Changing level rebuilds rows under a cursor that has not moved, so the
    // click that descended would otherwise also fire whatever row lands beneath
    // it. Ignore row clicks for a beat after each level change.
    property bool settling: false

    readonly property int depth: levels.length
    readonly property var currentOpener: depth > 0 ? levels[depth - 1].opener : rootOpener
    readonly property var entries: currentOpener?.children?.values ?? []

    readonly property bool anyIcons: entries.some(e => String(e.icon ?? "") !== "")
    readonly property bool anyCheckable: entries.some(e => e.buttonType !== QsMenuButtonType.None)
    readonly property int checkColumn: anyCheckable ? 22 : 0
    readonly property int iconColumn: anyIcons ? Theme.menuIconSize + 8 : 0

    function hidden(entry, index) {
        // A leading separator, or a first row that just repeats the app name, is
        // noise once the menu has its own card.
        if (depth === 0 && index === 0 && entry.hasChildren && titleHint !== ""
            && String(entry.text).toLowerCase() === titleHint.toLowerCase()) return true;
        if (depth === 0 && entry.isSeparator && index <= 1) return true;
        return false;
    }

    function selectable(entry, index) {
        return !entry.isSeparator && entry.enabled && !hidden(entry, index);
    }

    function step(from, direction) {
        for (let i = from + direction; i >= 0 && i < entries.length; i += direction) {
            if (selectable(entries[i], i)) return i;
        }
        return from;
    }

    function settle() {
        settling = true;
        settleTimer.restart();
    }

    function enter(entry) {
        const opener = openerComponent.createObject(root, { menu: entry });
        if (!opener) return;

        levels = levels.concat([{ opener: opener, title: String(entry.text ?? "") }]);
        highlighted = step(-1, 1);
        settle();
    }

    function leave() {
        if (depth === 0) {
            close();
            return;
        }

        const remaining = levels.slice();
        const top = remaining.pop();
        levels = remaining;
        top.opener.destroy();
        highlighted = step(-1, 1);
        settle();
    }

    function activate(index) {
        if (settling) return;

        const entry = entries[index];
        if (!entry || !selectable(entry, index)) return;

        if (entry.hasChildren) {
            enter(entry);
            return;
        }

        entry.triggered();
        close();
    }

    // Clear the reactive list before tearing anything down, so no binding reads a
    // half-destroyed opener. Deepest first: an inner opener's entry is owned by
    // its parent's model.
    function reset() {
        const openers = levels;
        levels = [];
        for (let i = openers.length - 1; i >= 0; i--) openers[i].opener.destroy();
        settling = false;
        settleTimer.stop();
    }

    function close() {
        root.visible = false;
    }

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: Theme.menuGap
    anchor.adjustment: PopupAdjustment.Slide

    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight
    color: "transparent"
    grabFocus: true

    onHandleChanged: reset()

    onVisibleChanged: {
        if (visible) highlighted = step(-1, 1);
        else reset();
    }

    // No focus grab. HyprlandFocusGrab clears the moment anything outside its
    // window list is clicked, and the click that opens the menu is still being
    // delivered to the bar then — so the menu closed instantly, and delaying the
    // grab only moved when it died. Dismissal is Escape, picking an entry, or
    // right-clicking the same tray icon again.

    Component {
        id: openerComponent

        QsMenuOpener {}
    }

    QsMenuOpener {
        id: rootOpener

        menu: root.handle
    }

    Timer {
        id: settleTimer

        interval: 250

        onTriggered: root.settling = false
    }

    // Rows have to fill the card's width, and the card's width comes from its
    // content — so asking the rows how wide they are is circular and collapses to
    // the minimum. Measure the labels off-screen instead and size from that.
    Item {
        visible: false

        Column {
            id: measure

            Repeater {
                model: root.currentOpener?.children ?? null

                Text {
                    required property var modelData

                    text: modelData.text ?? ""
                    font.family: Theme.fontFamily
                    font.pointSize: Theme.fontSize
                }
            }
        }
    }

    Rectangle {
        id: card

        anchors.fill: parent
        implicitWidth: Math.max(200, measure.implicitWidth + root.checkColumn + root.iconColumn
                                     + arrowWidth.implicitWidth + Theme.menuPadding * 4)
        implicitHeight: column.implicitHeight + Theme.menuPadding * 2
        color: Theme.menuBackground
        radius: Theme.menuRadius
        border.width: Theme.menuBorderWidth
        border.color: Theme.menuBorder
        opacity: root.visible ? 1 : 0

        focus: true

        Behavior on opacity {
            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
        }

        Keys.onUpPressed: root.highlighted = root.step(root.highlighted, -1)
        Keys.onDownPressed: root.highlighted = root.step(root.highlighted, 1)
        Keys.onRightPressed: root.activate(root.highlighted)
        Keys.onLeftPressed: root.leave()
        Keys.onEscapePressed: root.leave()
        Keys.onReturnPressed: root.activate(root.highlighted)
        Keys.onEnterPressed: root.activate(root.highlighted)

        // Reserves the submenu arrow's width even on menus that have none, so
        // entering a submenu does not resize the card.
        Text {
            id: arrowWidth

            visible: false
            text: "›"
            font.family: Theme.fontFamily
            font.pointSize: Theme.fontSize
        }

        Column {
            id: column

            anchors.fill: parent
            anchors.margins: Theme.menuPadding
            spacing: 0

            Item {
                width: column.width
                height: root.depth > 0 ? Theme.menuRowHeight : 0
                visible: root.depth > 0

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "‹  " + (root.depth > 0 ? root.levels[root.depth - 1].title : "")
                    color: Theme.muted
                    elide: Text.ElideRight
                    width: parent.width
                    font.family: Theme.fontFamily
                    font.pointSize: Theme.fontSize
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.leave()
                }
            }

            Repeater {
                model: root.currentOpener?.children ?? null

                Item {
                    id: row

                    required property var modelData
                    required property int index

                    readonly property bool skip: root.hidden(modelData, index)
                    readonly property bool selectable: root.selectable(modelData, index)

                    visible: !skip
                    width: column.width
                    height: skip ? 0
                          : modelData.isSeparator ? Theme.menuSeparatorHeight
                          : Theme.menuRowHeight
                    // Disabled entries dim wholesale rather than only greying
                    // their text, so the row reads as one unavailable thing.
                    opacity: modelData.enabled ? 1 : 0.45

                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: 1
                        anchors.bottomMargin: 1
                        visible: row.selectable && root.highlighted === row.index
                        radius: Math.max(2, Theme.menuRadius - 2)
                        color: Theme.menuHighlight
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        visible: row.modelData.isSeparator && !row.skip
                        height: 1
                        color: Theme.menuBorder
                        opacity: 0.45
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.checkColumn
                        horizontalAlignment: Text.AlignHCenter
                        visible: root.checkColumn > 0 && !row.modelData.isSeparator
                        text: row.modelData.checkState === Qt.Checked ? "" : ""
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pointSize: Theme.fontSize
                    }

                    Image {
                        anchors.left: parent.left
                        anchors.leftMargin: root.checkColumn
                        anchors.verticalCenter: parent.verticalCenter
                        visible: root.iconColumn > 0 && String(row.modelData.icon ?? "") !== ""
                        width: Theme.menuIconSize
                        height: Theme.menuIconSize
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: Theme.menuIconSize
                        sourceSize.height: Theme.menuIconSize
                        source: row.modelData.icon ?? ""
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: root.checkColumn + root.iconColumn
                        anchors.right: parent.right
                        anchors.rightMargin: arrowWidth.implicitWidth + 8
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !row.modelData.isSeparator
                        elide: Text.ElideRight
                        text: row.modelData.text
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pointSize: Theme.fontSize
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        visible: row.modelData.hasChildren && !row.skip
                        text: visible ? "›" : ""
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pointSize: Theme.fontSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: row.selectable

                        onEntered: root.highlighted = row.index
                        onClicked: root.activate(row.index)
                    }
                }
            }
        }
    }
}
