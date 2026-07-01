import QtQuick
import "../widgets"

// Per-monitor workspace strip. Populates from the Workspaces singleton;
// empty when running under niri (niri IPC lands in a follow-up).
Item {
    id: root
    required property var screen

    WorkspaceStrip {
        anchors.centerIn: parent
        screen: root.screen
    }
}
