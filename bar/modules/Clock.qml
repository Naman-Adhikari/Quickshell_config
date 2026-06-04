import QtQuick
import QtQuick.Layouts

Rectangle {
    implicitWidth: 35
    implicitHeight: 90

    color: "#101510"

    border.width: 1
    border.color: "#0d9104"

    QtObject {
        id: time
        property date date: new Date()
    }

    Timer {
        interval: 5000
        running: true
        repeat: true

        onTriggered: {
            time.date = new Date()
        }
    }

    Column {
        anchors.centerIn: parent

        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatTime(time.date, "HH")

            color: "#7cff75"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            font.bold: true

            renderType: Text.NativeRendering
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatTime(time.date, "mm")

            color: "#7cff75"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            font.bold: true

            renderType: Text.NativeRendering
        }

        Rectangle {
            width: 18
            height: 1

            color: "#0d9104"

            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatDate(time.date, "ddd").toUpperCase()

            color: "#55d95a"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 9

            renderType: Text.NativeRendering
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatDate(time.date, "dd")

            color: "#55d95a"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 9

            renderType: Text.NativeRendering
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatDate(time.date, "MMM").toUpperCase()

            color: "#55d95a"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 9

            renderType: Text.NativeRendering
        }
    }
}
