import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

import "./"

PanelWindow {
    id: panel

    visible: false

    readonly property color accent: "#2d7a46"
    readonly property color accentBright: "#3f9d5c"
    readonly property color textColor: "#b8d8b8"
    readonly property color panelBg: "#0a0f0a"
    readonly property color panelInner: "#080c08"
    readonly property color cardBg: "#0d140d"
    readonly property color itemBg: "#0b110b"
    readonly property color itemHover: "#132013"
    readonly property color mutedText: "#6e8a6e"

    anchors {
        right: true
        bottom: true
    }

    implicitWidth: 380
    implicitHeight: 560

    color: "transparent"

    Rectangle {
        anchors.fill: parent

        color: panel.panelBg

        border.width: 2
        border.color: panel.accent

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2

            color: panel.panelInner

            border.width: 1
            border.color: panel.accent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18

            spacing: 14

            Label {
                text: "󰖩 Wi-Fi"

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 24
                font.bold: true

                color: panel.accentBright
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 90

                color: panel.cardBg

                border.width: 1
                border.color: panel.accent

                Column {
                    anchors.fill: parent
                    anchors.margins: 12

                    spacing: 6

                    Label {
                        text: WifiService.connected
                            ? "Connected"
                            : "Disconnected"

                        color: panel.accentBright
                        font.bold: true
                    }

                    Label {
                        text: WifiService.connected
                            ? WifiService.ssid
                            : "No active network"

                        color: panel.textColor
                    }

                    Label {
                        text: WifiService.connected
                            ? "Signal: " + WifiService.strength + "%"
                            : ""

                        color: panel.mutedText
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Label {
                    text: "Wireless Radio"

                    color: panel.textColor
                    Layout.fillWidth: true
                }

                Switch {
                    checked: WifiService.enabled

                    onClicked: {
                        toggle.running = true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1

                color: panel.accent
                opacity: 0.25
            }

            Label {
                text: "Available Networks"

                color: panel.accentBright
                font.bold: true
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true

                ListView {
                    id: wifiList

                    model: wifiModel

                    spacing: 6

                    delegate: Rectangle {
                        required property string ssid
                        required property string signal

                        width: wifiList.width
                        height: 64

                        color: mouse.containsMouse
                            ? panel.itemHover
                            : panel.itemBg

                        border.width: 1
                        border.color: mouse.containsMouse
                            ? panel.accent
                            : "#162016"

                        MouseArea {
                            id: mouse

                            anchors.fill: parent

                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                connectProc.command = [
                                    "nmcli",
                                    "device",
                                    "wifi",
                                    "connect",
                                    ssid
                                ]

                                connectProc.running = true
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12

                            spacing: 12

                            Label {
                                text: "󰤨"

                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 18

                                color: panel.accentBright
                            }

                            ColumnLayout {
                                Layout.fillWidth: true

                                Label {
                                    text: ssid

                                    color: panel.textColor
                                    font.bold: true

                                    elide: Text.ElideRight
                                }

                                Label {
                                    text: "Signal Strength"

                                    color: panel.mutedText
                                    font.pixelSize: 11
                                }
                            }

                            Label {
                                text: signal + "%"

                                color: panel.accentBright
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: wifiModel
    }

    Process {
        id: scan

        command: [
            "nmcli",
            "-t",
            "-f",
            "SSID,SIGNAL",
            "device",
            "wifi",
            "list"
        ]

        stdout: SplitParser {
            onRead: data => {
                wifiModel.clear()

                for (let line of data.trim().split("\n")) {
                    let parts = line.split(":")

                    if (parts.length < 2)
                        continue

                    wifiModel.append({
                        ssid: parts[0],
                        signal: parts[1]
                    })
                }
            }
        }
    }

    Process {
        id: connectProc
    }

    Process {
        id: toggle

        command: [
            "nmcli",
            "radio",
            "wifi",
            WifiService.enabled ? "off" : "on"
        ]
    }

    onVisibleChanged: {
        console.log("WifiPanel visible:", visible)

        if (visible)
            scan.running = true
    }
}
