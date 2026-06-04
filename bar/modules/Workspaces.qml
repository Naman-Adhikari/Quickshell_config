import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ColumnLayout {
    id: root

    property int activeWorkspace: 1

    spacing: 4

    readonly property int firstVisibleWorkspace:
        Math.max(1, Math.min(activeWorkspace - 2, 5))

    Repeater {
        model: 5

        Rectangle {
            required property int index

            readonly property int workspaceId:
                root.firstVisibleWorkspace + index

            readonly property bool active:
                workspaceId === root.activeWorkspace

            implicitWidth: 35
            implicitHeight: active ? 30 : 24

            radius: 0

            color: active ? "#235b1f" : "#101510"

            border.width: active ? 2 : 1
            border.color: "#235b1f"

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: 120
                }
            }

            Text {
                anchors.centerIn: parent

                text: workspaceId

                color: active ? "#7cff75" : "#55d95a"

                font.family: "Iosevka Nerd Font"
                font.pixelSize: 11
                font.bold: active

                renderType: Text.NativeRendering
            }

            MouseArea {
                anchors.fill: parent

            onClicked: {
    if (workspaceId === root.activeWorkspace)
        return

    // Immediate UI feedback
    root.activeWorkspace = workspaceId

    switchWorkspace.command = [
        "mmsg",
        "dispatch",
        "view," + workspaceId + ",0"
    ]

    switchWorkspace.running = true
}
}
        }
    }

    Process {
        id: switchWorkspace
    }

    Process {
        id: workspacePoll

        command: [
            "mmsg",
            "get",
            "tags",
            "eDP-1"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text)

                    for (const tag of data.tags) {
                        if (tag.is_active) {
                            if (root.activeWorkspace !== tag.index)
                                root.activeWorkspace = tag.index

                            break
                        }
                    }
                } catch (e) {
                    console.log(
                        "[Workspace]",
                        "Failed to parse tag data:",
                        e
                    )
                }
            }
        }
    }

    Component.onCompleted: {
        workspacePoll.running = true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            if (!workspacePoll.running)
                workspacePoll.running = true
        }
    }
}
