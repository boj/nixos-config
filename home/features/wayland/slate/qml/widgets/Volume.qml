import QtQuick
import Quickshell.Services.Pipewire
import ".."

// Volume indicator: glyph on top, integer percent below. Middle-click to
// mute; scroll-wheel to adjust ±5% (clamped 0–150%). Auto-hides when
// there's no default audio sink.
//
// Pipewire's PwNodeAudio.volume is linear (0.0–1.0). wpctl and most
// system UIs display cubic (perceptual) volume, so we cube-root for
// display and cube-back when setting to keep parity with what the user
// sees elsewhere.
Item {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property real linearVol: audio ? audio.volume : 0
    readonly property real perceptual: Math.cbrt(linearVol)
    readonly property bool muted: audio ? audio.muted : false

    function setPerceptual(p) {
        if (!audio) return;
        const clamped = Math.max(0, Math.min(1.5, p));
        audio.volume = Math.pow(clamped, 3);
    }

    implicitWidth: 32
    implicitHeight: col.implicitHeight
    visible: audio !== null

    // PwNodeAudio.{volume,muted,volumes} are invalid unless the node is
    // bound via PwObjectTracker. Without this, volume reads back as 0
    // regardless of the actual system volume.
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.muted ? "\u00d7" : "\u266a" // × or ♪
            color: root.muted ? Colors.textMuted : Colors.text
            font.pixelSize: 22
            font.family: "monospace"
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(root.perceptual * 100).toString()
            color: root.muted ? Colors.textMuted : Colors.text
            opacity: root.muted ? 0.5 : 1.0
            font.pixelSize: 13
            font.family: "monospace"
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: event => {
            if (event.button === Qt.MiddleButton && root.audio) {
                root.audio.muted = !root.audio.muted;
            }
        }
        onWheel: event => {
            const delta = event.angleDelta.y > 0 ? 0.05 : -0.05;
            root.setPerceptual(root.perceptual + delta);
        }
    }
}
