import QtQuick
import "../widgets"

// Battery (worky-only via Config.showBattery), volume, and system tray.
// Media, tailscale, notifications, and the quick-settings drawer come in
// later steps. Column skips invisible children in layout, so widgets that
// hide themselves (Battery when no device, Volume when no sink, Tray when
// empty) collapse cleanly without leaving gaps.
Column {
    id: root
    spacing: 14

    Battery {
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Volume {
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Tray {
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
