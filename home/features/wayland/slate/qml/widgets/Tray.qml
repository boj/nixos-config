import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

// System tray icon column. Left-click activates, middle-click triggers
// the item's secondary action, right-click opens the item's context
// menu, scroll adjusts (used by volume/brightness tray items).
Column {
    id: root
    spacing: 6
    visible: SystemTray.items.values.length > 0

    // The Bar's PanelWindow. Plumbed in from BottomZone -> Bar so
    // QsMenuAnchor can parent its popup to the correct Quickshell
    // window; QtQuick's `Window.window` attached property returns the
    // raw QQuickWindow which QsMenuAnchor silently refuses on
    // layer-shell surfaces (was the "right-click does nothing" bug).
    property var panelWindow: null

    Repeater {
        model: SystemTray.items

        // Outer element is the MouseArea itself so nothing (IconImage,
        // stray Item bounds) can shadow right/middle-click hits.
        delegate: MouseArea {
            id: item
            required property SystemTrayItem modelData

            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: 24
            implicitHeight: 24
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            IconImage {
                anchors.fill: parent
                source: item.modelData.icon
                asynchronous: true
            }

            // Anchor for the per-item context menu. We key on `menu`
            // being non-null rather than `hasMenu` because some SNI
            // apps publish a menu object without setting the
            // ItemIsMenu hint, which makes `hasMenu` read false.
            QsMenuAnchor {
                id: menuAnchor
                menu: item.modelData.menu
                anchor.window: root.panelWindow
                anchor.rect.x: item.mapToItem(null, item.width, 0).x
                anchor.rect.y: item.mapToItem(null, 0, 0).y
                anchor.rect.width: 1
                anchor.rect.height: item.height
                anchor.edges: Edges.Right
                anchor.gravity: Edges.Right
            }

            onClicked: event => {
                if (event.button === Qt.LeftButton) {
                    item.modelData.activate();
                } else if (event.button === Qt.MiddleButton) {
                    item.modelData.secondaryActivate();
                } else if (event.button === Qt.RightButton) {
                    if (item.modelData.menu) {
                        menuAnchor.open();
                    } else {
                        // No menu handle at all — fall back to the
                        // item's secondary activation (a no-op for
                        // most apps, but the only thing left to try).
                        item.modelData.secondaryActivate();
                    }
                }
            }
            onWheel: event => {
                if (event.angleDelta.y !== 0) {
                    item.modelData.scroll(event.angleDelta.y / 120, false);
                } else if (event.angleDelta.x !== 0) {
                    item.modelData.scroll(event.angleDelta.x / 120, true);
                }
            }
        }
    }
}
