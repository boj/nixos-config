import QtQuick
import Quickshell
import ".."

// Stacked clock: HH on top of MM, small day + date below. Monospace so
// digits don't jitter on width changes.
Column {
    id: root
    spacing: 0

    SystemClock {
        id: sysClock
        precision: SystemClock.Minutes
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(sysClock.date, "HH")
        color: Colors.text
        font.family: "monospace"
        font.pixelSize: 20
        font.weight: Font.DemiBold
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(sysClock.date, "mm")
        color: Colors.text
        font.family: "monospace"
        font.pixelSize: 20
        font.weight: Font.DemiBold
    }

    Item { width: 1; height: 10 }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(sysClock.date, "ddd").toUpperCase()
        color: Colors.textMuted
        font.family: "monospace"
        font.pixelSize: 10
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(sysClock.date, "MM/dd")
        color: Colors.textMuted
        font.family: "monospace"
        font.pixelSize: 10
    }
}
