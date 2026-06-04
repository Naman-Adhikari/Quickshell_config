import QtQuick

Rectangle {
    id: root

    signal toggleRequested()

    width: 24
    height: 24

    color: "#101510"

    border.width: 1
    border.color: "#0d9104"

    Text {
        anchors.centerIn: parent

        text: "󰅌"

        color: "#72ffb2"

        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13
    }

    MouseArea {
        anchors.fill: parent

        onClicked: root.toggleRequested()
    }
}
