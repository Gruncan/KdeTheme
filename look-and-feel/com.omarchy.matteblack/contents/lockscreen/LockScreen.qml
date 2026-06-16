import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root

    readonly property color clrFg:     "#bebebe"
    readonly property color clrAccent: "#e68e0d"
    readonly property color clrDim:    "#8a8a8d"
    readonly property color clrError:  "#D35F5F"

    property bool failed: false

    Connections {
        target: authenticator
        function onFailed() {
            root.failed = true
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
        function onSucceeded() {
            root.failed = false
        }
        function onErrorMessage(msg) {
            root.failed = true
        }
    }

    // Background
    Image {
        anchors.fill: parent
        source:       Qt.resolvedUrl("../images/2-dot-hands.jpg")
        fillMode:     Image.PreserveAspectCrop
        cache:        false
    }

    Rectangle {
        anchors.fill: parent
        color:        Qt.rgba(0.071, 0.071, 0.071, 0.65)
    }

    // Time display — top right
    Text {
        id: timeDisplay
        anchors.top:         parent.top
        anchors.right:       parent.right
        anchors.topMargin:   44
        anchors.rightMargin: 52
        text:                Qt.formatTime(new Date(), "HH:mm")
        color:               root.clrDim
        font.family:         "JetBrains Mono"
        font.pixelSize:      18
        font.letterSpacing:  2
    }

    Timer {
        interval: 60000
        running:  true
        repeat:   true
        onTriggered: timeDisplay.text = Qt.formatTime(new Date(), "HH:mm")
    }

    // Centre: password field
    Column {
        anchors.centerIn: parent
        spacing: 14

        Rectangle {
            width:  280
            height: 44
            color:  "transparent"
            border.color: root.failed
                ? root.clrError
                : passwordField.activeFocus
                    ? root.clrAccent
                    : Qt.rgba(0.74, 0.74, 0.74, 0.18)
            border.width: 1

            Row {
                anchors.left:           parent.left
                anchors.leftMargin:     16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5
                clip:    true

                Repeater {
                    model: Math.min(passwordField.text.length, 22)
                    Rectangle {
                        width:  7
                        height: 7
                        radius: 3.5
                        color:  root.failed ? root.clrError : root.clrFg
                    }
                }
            }

            TextInput {
                id: passwordField
                anchors.fill:        parent
                anchors.leftMargin:  16
                anchors.rightMargin: 16
                verticalAlignment:   TextInput.AlignVCenter
                echoMode:            TextInput.Password
                passwordCharacter:   " "
                color:               "transparent"
                selectionColor:      "transparent"
                selectedTextColor:   "transparent"
                cursorDelegate:      Item {}
                font.family:         "JetBrains Mono"
                font.pixelSize:      14
                clip:                true
                focus:               true

                onTextChanged: root.failed = false

                Keys.onReturnPressed: {
                    if (text.length > 0) {
                        authenticator.tryUnlock(text)
                    }
                    event.accepted = true
                }
                Keys.onEscapePressed: {
                    text = ""
                    root.failed = false
                }
            }
        }
    }

    Component.onCompleted: passwordField.forceActiveFocus()
}
