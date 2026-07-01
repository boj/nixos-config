import QtQuick
import ".."

// Per-monitor workspace dots. Union of Config.persistentWorkspaces[monitor]
// and the live-populated workspaces from the Workspaces singleton, sorted
// by ID. Empty slots render dim; populated slots render text-colored;
// focused slots render accent with a soft glow. All state changes
// animated via Dimensions.transitionMs (spring-like OutCubic).
Column {
    id: root
    required property var screen
    spacing: 8

    // Compute the merged slot list. Reactive on Workspaces.workspaces
    // changes (live state) but persistent list is static per rebuild.
    readonly property var slots: {
        const monName = root.screen.name;
        const activeById = new Map(
            Workspaces.workspaces
                .filter(w => w.monitor === monName)
                .map(w => [w.id, w])
        );
        const persistent =
            Config.persistentWorkspaces[monName]
            || Config.persistentWorkspaces["*"]
            || [];
        const allIds = Array.from(new Set([...activeById.keys(), ...persistent]));
        return allIds
            .sort((a, b) => a - b)
            .map(id => {
                const w = activeById.get(id);
                return {
                    id: id,
                    focused: w ? w.focused : false,
                    populated: w ? w.populated : false
                };
            });
    }

    Repeater {
        model: root.slots

        delegate: Item {
            id: slot
            required property var modelData

            readonly property bool isFocused: modelData.focused
            readonly property bool isPopulated: modelData.populated
            readonly property int diameter:
                isFocused ? 14 : (isPopulated ? 10 : 5)

            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: 20
            implicitHeight: 20

            // Soft glow behind focused workspace
            Rectangle {
                anchors.centerIn: parent
                width: slot.diameter + 8
                height: width
                radius: width / 2
                color: Colors.accentGlow
                opacity: slot.isFocused ? 0.25 : 0
                Behavior on opacity { NumberAnimation { duration: Dimensions.transitionMs } }
            }

            // The dot itself
            Rectangle {
                id: dot
                anchors.centerIn: parent
                width: slot.diameter
                height: width
                radius: width / 2
                color: slot.isFocused ? Colors.accent
                     : slot.isPopulated ? Colors.text
                     : Colors.textMuted
                opacity: slot.isFocused ? 1.0 : (slot.isPopulated ? 0.75 : 0.35)

                Behavior on width {
                    NumberAnimation {
                        duration: Dimensions.transitionMs
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color { ColorAnimation { duration: Dimensions.transitionMs } }
                Behavior on opacity { NumberAnimation { duration: Dimensions.transitionMs } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Workspaces.focus(slot.modelData.id)
            }
        }
    }
}
