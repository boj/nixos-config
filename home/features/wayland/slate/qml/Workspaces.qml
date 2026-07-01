pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

// Compositor-agnostic workspace state. Wraps Quickshell's Hyprland IPC
// today; niri support (via Quickshell.Io.Process + `niri msg --json
// event-stream`) lands in a follow-up. Under niri, `workspaces` is empty
// and the middle zone renders nothing.
//
// Exposed shape per workspace:
//   { monitor: string, id: int, focused: bool, populated: bool }
//
// `workspaces` is a bound property (not a function) so consumers can
// filter it reactively: `Workspaces.workspaces.filter(w => w.monitor === screen.name)`
Singleton {
    id: root

    readonly property string kind:
        Hyprland.monitors.values.length > 0 ? "hyprland" : "niri"

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
        // niri: TODO — Process { command: ["niri", "msg", "action", "focus-workspace", id] }
    }
}
