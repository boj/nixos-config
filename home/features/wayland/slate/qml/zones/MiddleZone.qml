import QtQuick
import "../widgets"

// Per-monitor workspace strip. Populates from the Workspaces singleton.
Item {
    id: root
    required property var screen

    WorkspaceStrip {
        anchors.centerIn: parent
        screen: root.screen
    }
}
