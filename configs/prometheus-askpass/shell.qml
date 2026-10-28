//@ pragma UseQApplication
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "theme" as PrometheusTheme

ShellRoot {
    id: shell
    PrometheusTheme.Theme { id: theme }
    readonly property string prompt: Quickshell.env("PROMETHEUS_ASKPASS_TEXT") || "Enter SSH passphrase:"
    readonly property string mode: Quickshell.env("SSH_ASKPASS_PROMPT") || ""
    readonly property bool pinPrompt: /\bPIN\b/.test(prompt)
    readonly property bool confirmation: mode === "confirm"
    readonly property bool information: mode === "none"
    property bool submitted: false

    function finish(accepted) {
        if (submitted || !responseSocket.connected) return;
        submitted = true;
        responseSocket.write(JSON.stringify({accepted: accepted, response: accepted ? (confirmation ? "yes" : information ? "" : responseInput.text) : ""}) + "\n");
        responseSocket.flush();
        responseInput.clear();
        // The adapter exits and terminates this instance after reading the reply.
    }

    Component.onCompleted: Quickshell.watchFiles = false

    Socket {
        id: responseSocket
        path: Quickshell.env("PROMETHEUS_ASKPASS_SOCKET") || ""
        connected: path.length > 0
        onError: Qt.quit()
        onConnectedChanged: if (!connected) Qt.quit()
    }

    PanelWindow {
        color: "transparent"
        focusable: false
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "prometheus-askpass-dim"
        anchors { left: true; right: true; top: true; bottom: true }
        Rectangle { anchors.fill: parent; color: "#66000000" }
    }

    PanelWindow {
        id: promptWindow
        color: "transparent"
        focusable: true
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: Math.min(560, screen ? screen.width - 48 : 560)
        implicitHeight: content.implicitHeight + 44
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "prometheus-askpass"

        Rectangle {
            anchors.fill: parent
            color: theme.panel
            border.width: 1
            border.color: theme.line
            radius: 4
            Keys.onEscapePressed: shell.finish(false)

            ColumnLayout {
                id: content
                anchors.fill: parent
                anchors.margins: 22
                spacing: 12

                Text {
                    Layout.fillWidth: true
                    text: shell.confirmation ? "SSH Confirmation" : shell.information ? "SSH Notice" : "SSH Authentication"
                    color: theme.prometheusInk
                    font.family: theme.titleFontFamily
                    font.pixelSize: 18
                    textFormat: Text.PlainText
                    renderType: Text.NativeRendering
                }
                Text {
                    Layout.fillWidth: true
                    text: shell.prompt
                    textFormat: Text.PlainText
                    wrapMode: Text.WrapAnywhere
                    color: theme.muted
                    font.family: theme.titleFontFamily
                    font.pixelSize: 12
                    renderType: Text.NativeRendering
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: theme.line }
                Rectangle {
                    visible: !shell.confirmation && !shell.information
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#a0060909"
                    border.width: 1
                    border.color: "#263033"
                    radius: 4
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 14
                        color: theme.panelSoft
                        border.width: 1
                        border.color: "#405052"
                        radius: 3
                        TextInput {
                            id: responseInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            color: theme.prometheusInk
                            selectionColor: "#b8c3c0"
                            selectedTextColor: "#030606"
                            echoMode: TextInput.Password
                            passwordCharacter: "*"
                            font.family: theme.fontFamily
                            font.pixelSize: 12
                            font.preferShaping: false
                            font.preferTypoLineMetrics: true
                            renderType: Text.NativeRendering
                            clip: true
                            focus: visible
                            enabled: !shell.submitted
                            onAccepted: shell.finish(true)
                            Keys.onEscapePressed: shell.finish(false)
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    TerminalButton {
                        visible: !shell.information
                        label: shell.confirmation ? "DENY" : "CANCEL"
                        onClicked: shell.finish(false)
                    }
                    TerminalButton {
                        id: acceptButton
                        label: shell.confirmation ? "ALLOW" : shell.information ? "CLOSE" : shell.pinPrompt ? "CONTINUE" : "UNLOCK"
                        primary: true
                        focus: shell.confirmation || shell.information
                        onClicked: shell.finish(true)
                    }
                }
            }
        }
    }

    component TerminalButton: Rectangle {
        id: button
        required property string label
        property bool primary: false
        signal clicked()
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        enabled: responseSocket.connected && !shell.submitted
        activeFocusOnTab: true
        radius: 3
        color: mouse.containsMouse ? (primary ? "#dce4e1" : "#10191b") : "#070d0e"
        border.width: 1
        border.color: activeFocus ? theme.prometheusInk : "#334044"
        Keys.onReturnPressed: button.clicked()
        Keys.onEnterPressed: button.clicked()
        Keys.onSpacePressed: button.clicked()
        Keys.onEscapePressed: shell.finish(false)
        Text {
            anchors.centerIn: parent
            text: button.label
            color: button.primary && mouse.containsMouse ? "#030606" : theme.prometheusInk
            font.family: theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.DemiBold
            renderType: Text.NativeRendering
        }
        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }
}
