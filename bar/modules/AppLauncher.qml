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
	color:"transparent"

    implicitWidth: 850
    implicitHeight: 600

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
        color: "#000000dd"

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

        color: "#090d09"

        border.width: 2
        border.color: "#00ff66"

        property var results: []

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2

            radius: 12
            color: "#0d120d"
        }

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            Text {
                text: "◢ SYSTEM APPLICATION LAUNCHER ◣"

                color: "#00ff66"

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

                color: "#101810"

                border.width: 1
                border.color: "#00ff66"

                Row {
                    anchors.fill: parent
                    anchors.margins: 10

                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text: ">"

                        color: "#00ff66"

                        font.pixelSize: 18
                        font.bold: true
                        font.family: "JetBrains Mono"
                    }

                    TextField {
                        id: search

                        width: parent.width - 40

                        focus: true

                        color: "#d0ffd0"

                        placeholderText: "Search applications..."
                        placeholderTextColor: "#4d8f4d"

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
                color: "#00ff66"
                opacity: 0.3
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
                           ? "#143014"
                           : "#0f150f"

                    border.width: mouse.containsMouse ? 1 : 0
                    border.color: "#00ff66"

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 14

                        text: modelData.name

                        color: "#c0ffc0"

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
