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

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: item
            required property SystemTrayItem modelData

            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: 24
            implicitHeight: 24

            IconImage {
                anchors.fill: parent
                source: item.modelData.icon
                asynchronous: true
            }

            // Anchor for the per-item context menu. `hasMenu` gates the
            // right-click handler so we don't try to open non-existent
            // menus (some tray items have no menu, only activate/secondary).
            QsMenuAnchor {
                id: menuAnchor
                menu: item.modelData.menu
                anchor.window: item.Window.window
                anchor.rect.x: item.mapToItem(null, item.width, 0).x
                anchor.rect.y: item.mapToItem(null, 0, 0).y
                anchor.rect.width: 1
                anchor.rect.height: item.height
                anchor.edges: Edges.Right
                anchor.gravity: Edges.Right
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: event => {
                    if (event.button === Qt.LeftButton) {
                        item.modelData.activate();
                    } else if (event.button === Qt.MiddleButton) {
                        item.modelData.secondaryActivate();
                    } else if (event.button === Qt.RightButton) {
                        if (item.modelData.hasMenu) {
                            menuAnchor.open();
                        } else {
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
}
