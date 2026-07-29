pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

// Compositor-agnostic workspace state. Wraps Quickshell's Hyprland IPC.
//
// Exposed shape per workspace:
//   { monitor: string, id: int, focused: bool, populated: bool }
//
// `workspaces` is a bound property (not a function) so consumers can
// filter it reactively: `Workspaces.workspaces.filter(w => w.monitor === screen.name)`
Singleton {
    id: root

    readonly property string kind: "hyprland"

    readonly property var workspaces: {
        if (kind !== "hyprland") return [];
        // Touch length to make this binding reactive when workspaces are
        // added/removed. Values are HyprlandWorkspace objects.
        const src = Hyprland.workspaces.values;
        return src.map(w => ({
            monitor: w.monitor ? w.monitor.name : null,
            id: w.id,
            focused: w.active,
            populated: (w.toplevels && w.toplevels.values.length > 0) || false
        })).sort((a, b) => a.id - b.id);
    }

    function focus(workspaceId) {
        if (kind === "hyprland") {
            Hyprland.dispatch(`workspace ${workspaceId}`);
        }
    }
}
