import QtQuick
import "../widgets"

// Battery (worky-only via Config.showBattery), volume, microphone, and
// system tray. Media, tailscale, notifications, and the quick-settings
// drawer come in later steps. Column skips invisible children in layout,
// so widgets that hide themselves (Battery when no device, Volume when
// no sink, Microphone when no source, Tray when empty) collapse cleanly
// without leaving gaps.
Column {
    id: root
    spacing: 14

    // The Bar's PanelWindow, plumbed down so widgets that spawn popups
    // (currently just Tray) can anchor them to the correct Quickshell
    // window. QtQuick's `Window.window` attached property returns the
    // raw QQuickWindow which QsMenuAnchor doesn't accept as a valid
    // popup parent on layer-shell surfaces.
    property var panelWindow: null

    Battery {
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Volume {
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Microphone {
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Tray {
        anchors.horizontalCenter: parent.horizontalCenter
        panelWindow: root.panelWindow
    }
}
