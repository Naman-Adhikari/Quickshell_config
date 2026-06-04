import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    property bool open: false

    visible: open
	focusable: true

    anchors {
        top: true
        bottom: true
        right: true
    }

    implicitWidth: 400

    exclusiveZone: 0

    color: "transparent"

    ListModel {
        id: clipboardModel
    }

    function loadHistory() {
        clipboardModel.clear()
        historyProcess.running = true
    }

		function toggleClipboard() {
    open = !open

    if (open) {
        loadHistory()
        historyView.forceActiveFocus()
    }
}
function openClipboard() {
    open = true
    loadHistory()
    historyView.forceActiveFocus()
}

function closeClipboard() {
    open = false
}

IpcHandler {
    target: "clipboard"

    function toggleClipboard() {
        root.toggleClipboard()
    }

    function openClipboard() {
        root.openClipboard()
    }

    function closeClipboard() {
        root.closeClipboard()
    }
}
    Rectangle {
        anchors.fill: parent

        color: "#0a0d0a"

        border.width: 1
        border.color: "#0d9104"

        Column {
            anchors.fill: parent

            anchors.margins: 6

            spacing: 4

            Text {
                text: "Clipboard"

                color: "#72ffb2"

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 19
            }

        ListView {
    id: historyView

    width: parent.width
    height: parent.height

    clip: true

    model: clipboardModel

    spacing: 2

    focus: root.open
    currentIndex: 0

    keyNavigationWraps: true

    highlight: Rectangle {
        color: "#173317"
        border.width: 1
        border.color: "#72ffb2"
    }

    highlightFollowsCurrentItem: true

Keys.onPressed: event => {
    if (event.key === Qt.Key_J) {
        currentIndex = Math.min(currentIndex + 1, clipboardModel.count - 1)
        event.accepted = true
        return
    }

    if (event.key === Qt.Key_K) {
        currentIndex = Math.max(currentIndex - 1, 0)
        event.accepted = true
        return
    }

    if (event.key === Qt.Key_Return ||
        event.key === Qt.Key_Enter) {

        if (currentIndex >= 0) {
            const item = clipboardModel.get(currentIndex)

            copyProcess.entryId = item.itemId
            copyProcess.running = true

            root.open = false
        }

        event.accepted = true
    }

    if (event.key === Qt.Key_Escape) {
        root.open = false
        event.accepted = true
    }
}
    delegate: Rectangle {
        required property string itemId
        required property string preview

        width: ListView.view.width
        height: 42

        color: ListView.isCurrentItem
            ? "#173317"
            : (mouse.containsMouse
                ? "#173317"
                : "#101510")

        border.width: 1
        border.color: ListView.isCurrentItem
            ? "#72ffb2"
            : "#0d9104"

        Text {
            anchors.fill: parent

            anchors.leftMargin: 6
            anchors.rightMargin: 6

            verticalAlignment: Text.AlignVCenter

            text: preview

            elide: Text.ElideRight

            color: "#72ffb2"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
        }


        MouseArea {
            id: mouse

            anchors.fill: parent

            hoverEnabled: true

            onClicked: {
                historyView.currentIndex = index

                copyProcess.entryId = itemId
                copyProcess.running = true

                root.open = false
            }
        }
    }
}
}
    }

    Process {
        id: historyProcess

        command: [
            "sh",
            "-c",
            "cliphist list"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")

                for (const line of lines) {
                    if (!line.trim())
                        continue

                    const firstSpace = line.indexOf(" ")

                    if (firstSpace < 0)
                        continue

                    clipboardModel.append({
                        itemId: line.substring(0, firstSpace),
                        preview: line.substring(firstSpace + 1)
                    })
                }
            }
        }
    }

    Process {
        id: copyProcess

        property string entryId: ""

        command: [
            "sh",
            "-c",
            `cliphist decode "${entryId}" | wl-copy`
        ]
    }

onOpenChanged: {
    if (open) {
        loadHistory()
        historyView.forceActiveFocus()
    }
}}
