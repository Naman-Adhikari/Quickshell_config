import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root

    property bool open: false

    visible: open
    focusable: true
    color: "transparent"

    implicitWidth: 850
    implicitHeight: 600

    readonly property color accent: "#2d7a46"
    readonly property color accentBright: "#3f9d5c"
    readonly property color textColor: "#b8d8b8"
    readonly property color panelBg: "#0a0f0a"
    readonly property color panelInner: "#080c08"
    readonly property color inputBg: "#0d140d"
    readonly property color itemBg: "#0b110b"
    readonly property color itemHover: "#132013"
    readonly property color placeholderColor: "#4f6b4f"

    function toggleLauncher() {
        open = !open

        if (open) {
            search.text = ""
            panel.results = AppService.search("")

            Qt.callLater(function() {
                search.forceActiveFocus()
            })
        }
    }

    function openLauncher() {
        open = true

        search.text = ""
        panel.results = AppService.search("")

        Qt.callLater(function() {
            search.forceActiveFocus()
        })
    }

    function closeLauncher() {
        open = false
    }

    IpcHandler {
        target: "launcher"

        function toggleLauncher() {
            root.toggleLauncher()
        }

        function openLauncher() {
            root.openLauncher()
        }

        function closeLauncher() {
            root.closeLauncher()
        }
    }

    Process {
        id: launcher
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000e6"

        MouseArea {
            anchors.fill: parent
            onClicked: root.open = false
        }
    }

    Rectangle {
        id: panel

        anchors.centerIn: parent
        width: 800
        height: 550

        radius: 14

        color: root.panelBg

        border.width: 2
        border.color: root.accent

        property var results: []

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2

            radius: 12
            color: root.panelInner
        }

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            Text {
                text: "◢ SYSTEM APPLICATION LAUNCHER ◣"

                color: root.accentBright

                font.pixelSize: 18
                font.bold: true
                font.family: "JetBrains Mono"

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        root.open = false
                        event.accepted = true
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 54

                radius: 8

                color: root.inputBg

                border.width: 1
                border.color: root.accent

                Row {
                    anchors.fill: parent
                    anchors.margins: 10

                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text: ">"

                        color: root.accentBright

                        font.pixelSize: 18
                        font.bold: true
                        font.family: "JetBrains Mono"
                    }

                    TextField {
                        id: search

                        width: parent.width - 40

                        focus: true

                        color: root.textColor

                        placeholderText: "Search applications..."
                        placeholderTextColor: root.placeholderColor

                        font.family: "JetBrains Mono"

                        background: Rectangle {
                            color: "transparent"
                        }

                        onTextChanged: {
                            panel.results = AppService.search(text)
                        }

                        onAccepted: {
                            if (panel.results.length > 0) {
                                launcher.command = [
                                    "sh",
                                    "-c",
                                    panel.results[0].exec
                                ]

                                launcher.running = true
                                root.open = false
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: root.accent
                opacity: 0.25
            }

            ListView {
                id: list

                width: parent.width
                height: parent.height - 120

                clip: true
                spacing: 4

                model: panel.results

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 42

                    radius: 6

                    color: mouse.containsMouse
                           ? root.itemHover
                           : root.itemBg

                    border.width: mouse.containsMouse ? 1 : 0
                    border.color: root.accent

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 14

                        text: modelData.name

                        color: root.textColor

                        font.pixelSize: 14
                        font.family: "JetBrains Mono"
                    }

                    MouseArea {
                        id: mouse

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            launcher.command = [
                                "sh",
                                "-c",
                                modelData.exec
                            ]

                            launcher.running = true
                            root.open = false
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: AppService

        function onToggleRequested() {
            root.open = !root.open

            if (root.open) {
                search.text = ""

                panel.results = AppService.search("")

                root.raise()
                root.requestActivate()

                Qt.callLater(function() {
                    search.forceActiveFocus()
                })
            }
        }
    }
}
