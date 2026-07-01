//@ pragma UseQApplication
import Quickshell
import QtQuick

ShellRoot {
    // One Bar instance per connected output. `Quickshell.screens` is a
    // reactive list; PanelWindows attached to a disconnected screen are
    // cleaned up automatically when it disappears.
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }
}
