import QtQuick
import Quickshell.Services.UPower
import ".."

// Battery status: charging bolt or level glyph on top, integer percent
// below. Color-coded: green (charging), red (<20%), yellow (<50%),
// default text otherwise. Auto-hides if no battery device is present.
Item {
    id: root

    readonly property var dev: UPower.displayDevice
    readonly property bool available: dev !== null && dev.ready
    readonly property real level: available ? dev.percentage : 0
    readonly property bool charging:
        available && dev.state === UPowerDeviceState.Charging

    readonly property color statusColor:
        !available   ? Colors.textMuted :
        charging     ? Colors.success   :
        level < 20   ? Colors.error     :
        level < 50   ? Colors.warning   :
                       Colors.text

    implicitWidth: 32
    implicitHeight: col.implicitHeight

    // Config.showBattery is the user override; `available` gates on hardware.
    visible: Config.showBattery && available

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.charging ? "\u26a1" : "\u25a4" // ⚡ or ▤
            color: root.statusColor
            font.pixelSize: 22
            font.family: "monospace"
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(root.level).toString()
            color: root.statusColor
            font.pixelSize: 13
            font.family: "monospace"
            font.weight: Font.DemiBold
        }
    }
}
