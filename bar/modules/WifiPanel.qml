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

    anchors {
        right: true
        bottom: true
    }

    implicitWidth: 380
    implicitHeight: 560

    color: "transparent"

    Rectangle {
        anchors.fill: parent

        radius: 0

        color: "#0a0f0a"

        border.width: 2
        border.color: "#39ff14"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2

            radius: 0

            color: "#101510"

            border.width: 1
            border.color: "#1f8f1f"
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

                color: "#39ff14"
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 90

                radius: 1

                color: "#151f15"

                border.width: 1
                border.color: "#39ff14"

                Column {
                    anchors.fill: parent
                    anchors.margins: 12

                    spacing: 6

                    Label {
                        text: WifiService.connected
                            ? "Connected"
                            : "Disconnected"

                        color: "#39ff14"
                        font.bold: true
                    }

                    Label {
                        text: WifiService.connected
                            ? WifiService.ssid
                            : "No active network"

                        color: "#d0ffd0"
                    }

                    Label {
                        text: WifiService.connected
                            ? "Signal: " + WifiService.strength + "%"
                            : ""

                        color: "#88aa88"
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Label {
                    text: "Wireless Radio"

                    color: "#d0ffd0"
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

                color: "#1f8f1f"
            }

            Label {
                text: "Available Networks"

                color: "#39ff14"
                font.bold: true
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true

                ListView {
                    id: wifiList

                    model: wifiModel

                    spacing: 8

                    delegate: Rectangle {
                        required property string ssid
                        required property string signal

                        width: wifiList.width
                        height: 64

                        radius: 1

                        color: "#151f15"

                        border.width: 1
                        border.color: "#1f8f1f"

                        MouseArea {
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

                                color: "#39ff14"
                            }

                            ColumnLayout {
                                Layout.fillWidth: true

                                Label {
                                    text: ssid

                                    color: "#d0ffd0"
                                    font.bold: true

                                    elide: Text.ElideRight
                                }

                                Label {
                                    text: "Signal Strength"

                                    color: "#88aa88"
                                    font.pixelSize: 11
                                }
                            }

                            Label {
                                text: signal + "%"

                                color: "#39ff14"
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
