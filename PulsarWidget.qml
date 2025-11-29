import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property int battery: 0
    property int dpi: 800
    property int stage: 1
    property bool connected: false

    property int refreshInterval: pluginData.refreshInterval || 10000

    Timer {
        id: startupTimer
        interval: 500
        running: true
        repeat: false
        onTriggered: {
            fetchProcess.running = true
            refreshTimer.running = true
        }
    }

    Timer {
        id: refreshTimer
        interval: root.refreshInterval
        running: false
        repeat: true
        onTriggered: fetchProcess.running = true
    }

    function parseInfo(output) {
        if (output.includes("Found: Pulsar X3")) {
            root.connected = true

            var batteryMatch = output.match(/Battery:\s*(\d+)%/)
            if (batteryMatch) root.battery = parseInt(batteryMatch[1])

            var dpiMatch = output.match(/DPI:\s*(\d+)\s*\(stage\s*(\d+)\)/)
            if (dpiMatch) {
                root.dpi = parseInt(dpiMatch[1])
                root.stage = parseInt(dpiMatch[2])
            }
        } else {
            root.connected = false
        }
    }

    property string fetchOutput: ""

    Process {
        id: fetchProcess
        command: ["pulsar-x3", "--info"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                root.fetchOutput += data + "\n"
            }
        }
        onExited: (exitCode, exitStatus) => {
            root.parseInfo(root.fetchOutput)
            root.fetchOutput = ""
        }
    }

    Process {
        id: dpiProcess
        running: false
        onExited: (exitCode, exitStatus) => {
            fetchProcess.running = true
        }
    }

    Process {
        id: stageProcess
        running: false
        onExited: (exitCode, exitStatus) => {
            fetchProcess.running = true
        }
    }

    function setDpi(dpi) {
        dpiProcess.command = ["pulsar-x3", "--dpi", dpi.toString()]
        dpiProcess.running = true
    }

    function setStage(stage) {
        stageProcess.command = ["pulsar-x3", "--stage", stage.toString()]
        stageProcess.running = true
    }

    horizontalBarPill: Component {
        Row {
            spacing: 8

            DankIcon {
                name: "mouse"
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.connected ? root.battery + "%" : "N/A"
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.connected ? root.dpi + " DPI" : ""
                font.pixelSize: Theme.fontSizeSmall
                opacity: 0.7
                visible: root.connected
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: 4

            DankIcon {
                name: "mouse"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.connected ? root.battery + "%" : "N/A"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: popout
            showCloseButton: true

            Component.onCompleted: {
                fetchProcess.running = true
            }

            Column {
                width: parent.width - Theme.spacingM
                anchors.horizontalCenter: parent.horizontalCenter
                topPadding: Theme.spacingS
                bottomPadding: Theme.spacingS
                spacing: Theme.spacingS

                // Header
                Row {
                    width: parent.width
                    height: 40
                    spacing: Theme.spacingS

                    StyledText {
                        text: "Pulsar X3 Mouse"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Normal
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - refreshButton.width - Theme.spacingS
                    }

                    StyledRect {
                        id: refreshButton
                        width: 32
                        height: 32
                        radius: Theme.cornerRadius
                        color: refreshMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent"
                        anchors.verticalCenter: parent.verticalCenter

                        DankIcon {
                            name: "refresh"
                            anchors.centerIn: parent
                            color: Theme.surfaceText
                        }

                        MouseArea {
                            id: refreshMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                fetchProcess.running = true
                            }
                        }
                    }
                }

                // Status row
                Row {
                    width: parent.width
                    spacing: Theme.spacingM

                    Column {
                        spacing: 2

                        StyledText {
                            text: "Battery"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }

                        StyledText {
                            text: root.connected ? root.battery + "%" : "N/A"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }
                    }

                    Column {
                        spacing: 2

                        StyledText {
                            text: "DPI"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }

                        StyledText {
                            text: root.connected ? root.dpi.toString() : "N/A"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }
                    }

                    Column {
                        spacing: 2

                        StyledText {
                            text: "Stage"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }

                        StyledText {
                            text: root.connected ? root.stage.toString() : "N/A"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }
                    }
                }

                Item { height: Theme.spacingXS }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.surfaceVariantText
                    opacity: 0.2
                }

                Item { height: Theme.spacingXS }

                // Quick DPI
                StyledText {
                    text: "Quick DPI"
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    color: Theme.surfaceVariantText
                }

                Row {
                    spacing: Theme.spacingS

                    Repeater {
                        model: [400, 800, 1600, 3200]

                        StyledRect {
                            width: 52
                            height: 32
                            radius: Theme.cornerRadius
                            color: {
                                if (root.dpi === modelData) {
                                    return Theme.primaryContainer
                                } else if (dpiMouse.containsMouse) {
                                    return Theme.surfaceContainerHighest
                                } else {
                                    return Theme.surfaceContainerHigh
                                }
                            }

                            StyledText {
                                text: modelData.toString()
                                anchors.centerIn: parent
                                color: root.dpi === modelData ? Theme.primary : Theme.surfaceText
                                font.weight: root.dpi === modelData ? Font.Medium : Font.Normal
                            }

                            MouseArea {
                                id: dpiMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.setDpi(modelData)
                                }
                            }
                        }
                    }
                }

                Item { height: Theme.spacingXS }

                // DPI Stage
                StyledText {
                    text: "DPI Stage"
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    color: Theme.surfaceVariantText
                }

                Row {
                    spacing: Theme.spacingS

                    Repeater {
                        model: 6

                        StyledRect {
                            width: 32
                            height: 32
                            radius: Theme.cornerRadius
                            color: {
                                if (root.stage === (index + 1)) {
                                    return Theme.primaryContainer
                                } else if (stageMouse.containsMouse) {
                                    return Theme.surfaceContainerHighest
                                } else {
                                    return Theme.surfaceContainerHigh
                                }
                            }

                            StyledText {
                                text: (index + 1).toString()
                                anchors.centerIn: parent
                                color: root.stage === (index + 1) ? Theme.primary : Theme.surfaceText
                                font.weight: root.stage === (index + 1) ? Font.Medium : Font.Normal
                            }

                            MouseArea {
                                id: stageMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.setStage(index + 1)
                                }
                            }
                        }
                    }
                }

                Item { height: Theme.spacingS }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.surfaceVariantText
                    opacity: 0.2
                }

                Item { height: Theme.spacingS }

                // Open Settings button
                StyledRect {
                    width: parent.width
                    height: 32
                    radius: Theme.cornerRadius
                    color: openMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh

                    Row {
                        anchors.centerIn: parent
                        spacing: Theme.spacingS

                        DankIcon {
                            name: "open_in_new"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Open Settings"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: openMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["pulsar-x3-gui"])
                            popout.closePopout()
                        }
                    }
                }
            }
        }
    }

    popoutWidth: 260
}
