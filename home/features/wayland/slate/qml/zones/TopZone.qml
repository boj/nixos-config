import QtQuick
import "../widgets"

// Stacked clock (HH/MM) + date. Widgets/ripple/gauges added in step 3.
Item {
    implicitHeight: clock.implicitHeight

    Clock {
        id: clock
        anchors.centerIn: parent
    }
}
