pragma Singleton

import QtQuick
import Quickshell

// All numeric constants for the bar in one place. Widgets and zones
// reference these instead of hardcoding pixels, so retuning the whole
// look-and-feel is a one-file change.
Singleton {
    // Overall geometry
    readonly property int barWidth: 40
    readonly property int edgeMargin: 16       // top/bottom padding inside the bar
    readonly property int contentMargin: 6     // left/right padding inside the bar
    readonly property int zoneGap: 40          // empty space between top/mid/bot zones

    // Widget primitives
    readonly property int iconSize: 20
    readonly property int hairline: 1
    readonly property int cornerRadius: 8
    readonly property int gaugeRingThickness: 3

    // Opacity/motion
    readonly property real backgroundOpacity: 0.85
    readonly property int transitionMs: 180
}
