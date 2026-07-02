import Quickshell
import QtQuick
import QtQuick.Layouts
import "zones"

PanelWindow {
    id: root

    // Anchor to left edge, full height. Reserves its own width from the
    // usable screen area via exclusiveZone.
    anchors {
        top: true
        left: true
        bottom: true
    }
    implicitWidth: Dimensions.barWidth
    exclusiveZone: Dimensions.barWidth

    // Transparent window; the visible surface is the Rectangle below so
    // we control opacity/blur/rounding ourselves.
    color: "transparent"

    // Background slab. Sharp on the outer (left/top/bottom) edges since
    // they hug the screen; will get inner corner rounding once we have
    // a proper masked container (step 2). For step 1 we keep it flat.
    Rectangle {
        anchors.fill: parent
        color: Colors.background
        opacity: Dimensions.backgroundOpacity
    }

    // Inner-edge hairline (facing content area).
    Rectangle {
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        width: Dimensions.hairline
        color: Colors.border
    }

    // Three-zone vertical layout. Zones are placeholders in step 1;
    // widgets get filled in during later steps.
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimensions.contentMargin
        anchors.rightMargin: Dimensions.contentMargin + Dimensions.hairline
        anchors.topMargin: Dimensions.edgeMargin
        anchors.bottomMargin: Dimensions.edgeMargin
        spacing: 0

        TopZone {
            Layout.fillWidth: true
        }

        // Muted separator inside the gap between zones.
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: Dimensions.zoneGap / 2
            Layout.bottomMargin: Dimensions.zoneGap / 2
            Layout.preferredHeight: Dimensions.hairline
            color: Colors.separator
        }

        MiddleZone {
            screen: root.screen
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: Dimensions.zoneGap / 2
            Layout.bottomMargin: Dimensions.zoneGap / 2
            Layout.preferredHeight: Dimensions.hairline
            color: Colors.separator
        }

        BottomZone {
            panelWindow: root
            Layout.fillWidth: true
        }
    }
}
