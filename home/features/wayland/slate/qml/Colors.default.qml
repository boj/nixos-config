pragma Singleton

import QtQuick
import Quickshell

// Fallback color palette (Catppuccin Mocha). Seeded into
// ~/.config/quickshell/slate/Colors.qml by the slate module's
// home.activation.slatePaletteBootstrap hook, then overwritten by matugen
// on each wallpaper change (see the slate-palette template in
// home/features/wayland/default.nix).
//
// Named `Colors` (not `Palette`) because `Palette` collides with QtQuick's
// built-in Palette type and gets shadowed — properties read as undefined.
//
// Live-edit ~/.config/quickshell/slate/Colors.qml directly — matugen will
// overwrite it on the next wallpaper change.
Singleton {
    readonly property color background:   "#1e1e2e"
    readonly property color surface:      "#181825"
    readonly property color surfaceAlt:   "#313244"

    readonly property color text:         "#cdd6f4"
    readonly property color textMuted:    "#a6adc8"

    readonly property color accent:       "#cba6f7"
    readonly property color accentText:   "#1e1e2e"
    readonly property color accentGlow:   "#cba6f7"

    readonly property color border:       "#313244"
    readonly property color separator:    "#313244"

    readonly property color error:        "#f38ba8"
    readonly property color warning:      "#f9e2af"
    readonly property color success:      "#a6e3a1"
    readonly property color info:         "#89b4fa"
}
