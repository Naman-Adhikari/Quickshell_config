import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    property bool open: false

    readonly property color accent: "#2d7a46"
    readonly property color accentBright: "#3f9d5c"
    readonly property color textColor: "#b8d8b8"
    readonly property color panelBg: "#0a0f0a"
    readonly property color itemBg: "#0b110b"
    readonly property color itemHover: "#132013"

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

        color: root.panelBg

        border.width: 1
        border.color: root.accent

        Column {
            anchors.fill: parent
            anchors.margins: 8

            spacing: 6

            Text {
                text: "Clipboard"

                color: root.accentBright

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 19
                font.bold: true
            }

            Rectangle {
                width: parent.width
                height: 1

                color: root.accent
                opacity: 0.25
            }

            ListView {
                id: historyView

                width: parent.width
                height: parent.height

                clip: true

                model: clipboardModel

                spacing: 3

                focus: root.open
                currentIndex: 0

                keyNavigationWraps: true

                highlight: Rectangle {
                    radius: 6

                    color: root.itemHover

                    border.width: 1
                    border.color: root.accent
                }

                highlightFollowsCurrentItem: true

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_J) {
                        currentIndex = Math.min(
                            currentIndex + 1,
                            clipboardModel.count - 1
                        )
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_K) {
                        currentIndex = Math.max(
                            currentIndex - 1,
                            0
                        )
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

                    radius: 6

                    color: ListView.isCurrentItem
                        ? root.itemHover
                        : (mouse.containsMouse
                            ? root.itemHover
                            : root.itemBg)

                    border.width: 1

                    border.color: ListView.isCurrentItem
                        ? root.accent
                        : "#162016"

                    Text {
                        anchors.fill: parent

                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        verticalAlignment: Text.AlignVCenter

                        text: preview

                        elide: Text.ElideRight

                        color: root.textColor

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
    }
}
