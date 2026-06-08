import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    width: 38
    height: 38
    radius: 8

    color: mouse.containsMouse
        ? "#143014"
        : "transparent"

    border.width: mouse.containsMouse ? 1 : 0
    border.color: "#000000"

    Text {
        anchors.centerIn: parent

        text: "󰀻"

        color: "#82e0a4"

        font.pixelSize: 20
        font.family: "JetBrainsMono Nerd Font"
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        onClicked: {
            AppService.toggle()
        }
    }
}
