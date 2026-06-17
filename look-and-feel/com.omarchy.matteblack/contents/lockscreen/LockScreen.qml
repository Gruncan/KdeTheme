import QtQuick 2.15
import QtQuick.VirtualKeyboard 2.1

Rectangle {
    id: root
    color: "#121212"

    readonly property color clrFg:     "#bebebe"
    readonly property color clrAccent: "#e68e0d"
    readonly property color clrDim:    "#8a8a8d"
    readonly property color clrError:  "#D35F5F"

    property bool   failed:    false
    property string loginName: ""

    function resolveLoginName() {
        try {
            var xhr = new XMLHttpRequest()
            xhr.open("GET", "file:///proc/self/status", false)
            xhr.send()
            var m = xhr.responseText.match(/^Uid:\s+(\d+)/m)
            if (!m) return
            var uid = m[1]
            xhr.open("GET", "file:///etc/passwd", false)
            xhr.send()
            var lines = xhr.responseText.split("\n")
            for (var i = 0; i < lines.length; i++) {
                var p = lines[i].split(":")
                if (p.length >= 3 && p[2] === uid) {
                    root.loginName = p[0]
                    return
                }
            }
        } catch(e) {}
    }

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
        function onErrorMessage() {
            root.failed = true
            passwordField.text = ""
            passwordField.forceActiveFocus()
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

    // Time — top right, dim, same position as SDDM
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

    // Centre: username label + password field
    Column {
        anchors.horizontalCenter:     parent.horizontalCenter
        anchors.verticalCenter:       parent.verticalCenter
        anchors.verticalCenterOffset: 66
        spacing: 10

        // System login name resolved from /proc/self/status + /etc/passwd
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:    root.loginName
            visible: root.loginName !== ""
            color:               root.clrDim
            font.family:         "JetBrains Mono"
            font.pixelSize:      13
            font.letterSpacing:  2
        }

        // Password field
        Rectangle {
            width:  280
            height: 44
            color:  Qt.rgba(0.65, 0.65, 0.65, 0.28)
            border.color: root.failed
                ? root.clrError
                : passwordField.activeFocus
                    ? root.clrAccent
                    : Qt.rgba(0.74, 0.74, 0.74, 0.18)
            border.width: (passwordField.activeFocus || root.failed) ? 2 : 1

            // Placeholder — shown when field is empty
            Text {
                anchors.left:           parent.left
                anchors.leftMargin:     16
                anchors.verticalCenter: parent.verticalCenter
                visible:                passwordField.text.length === 0
                text:                   "password"
                color:                  Qt.rgba(0.74, 0.74, 0.74, 0.45)
                font.family:            "JetBrains Mono"
                font.pixelSize:         14
                font.letterSpacing:     1
            }

            // Bullet dots
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

        // Error hint — only visible on failure
        Text {
            visible:                  root.failed
            anchors.horizontalCenter: parent.horizontalCenter
            text:                     "incorrect password"
            color:                    root.clrError
            font.family:              "JetBrains Mono"
            font.pixelSize:           11
            font.letterSpacing:       1
            opacity:                  0.8
        }
    }

    // Virtual keyboard — anchored to bottom, only visible when active (touch/accessibility).
    // Without this, Qt floats it in a broken position.
    InputPanel {
        id: inputPanel
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        visible:        active
    }

    Component.onCompleted: {
        resolveLoginName()
        passwordField.forceActiveFocus()
    }
}
