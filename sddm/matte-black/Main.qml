import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#121212"

    readonly property color clrFg:     "#bebebe"
    readonly property color clrAccent: "#e68e0d"
    readonly property color clrDim:    "#8a8a8d"
    readonly property color clrError:  "#D35F5F"

    property bool   loginFailed:  false
    property int    sessionIndex: sessionModel.lastIndex
    property string currentUser:  userModel.lastUser

    Connections {
        target: sddm
        function onLoginFailed() {
            loginFailed = true
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
        function onLoginSucceeded() {
            loginFailed = false
        }
    }

    // Background image
    Image {
        anchors.fill: parent
        source: config.background ? config.background : ""
        fillMode: Image.PreserveAspectCrop
        cache: false
    }

    // Dark overlay
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.071, 0.071, 0.071, 0.65)
    }

    // Time — top right, small, dim
    Text {
        id: timeDisplay
        anchors.top:    parent.top
        anchors.right:  parent.right
        anchors.topMargin:   44
        anchors.rightMargin: 52
        text:           Qt.formatTime(new Date(), "HH:mm")
        color:          root.clrDim
        font.family:    "JetBrains Mono"
        font.pixelSize: 18
        font.letterSpacing: 2
    }

    Timer {
        interval: 60000
        running:  true
        repeat:   true
        onTriggered: timeDisplay.text = Qt.formatTime(new Date(), "HH:mm")
    }

    // Centre column
    Column {
        anchors.centerIn: parent
        spacing: 14

        // Username field — hidden when a last-user is known
        Rectangle {
            visible: root.currentUser === ""
            width:   280
            height:  44
            color:   "transparent"
            border.color: userField.activeFocus
                ? root.clrAccent
                : Qt.rgba(0.74, 0.74, 0.74, 0.18)
            border.width: 1

            TextInput {
                id: userField
                anchors.fill:        parent
                anchors.leftMargin:  16
                anchors.rightMargin: 16
                verticalAlignment:   TextInput.AlignVCenter
                color:               root.clrFg
                selectionColor:      "#515151"
                selectedTextColor:   root.clrFg
                font.family:         "JetBrains Mono"
                font.pixelSize:      14
                font.letterSpacing:  1
                clip:                true
                focus:               root.currentUser === ""

                Text {
                    anchors.fill:          parent
                    verticalAlignment:     Text.AlignVCenter
                    text:                  "username"
                    color:                 root.clrDim
                    font:                  parent.font
                    visible:               parent.text.length === 0 && !parent.activeFocus
                }

                Keys.onTabPressed:   passwordField.forceActiveFocus()
                Keys.onReturnPressed: passwordField.forceActiveFocus()
            }
        }

        // Password field
        Rectangle {
            id: pwContainer
            width:  280
            height: 44
            color:  "transparent"
            border.color: root.loginFailed
                ? root.clrError
                : passwordField.activeFocus
                    ? root.clrAccent
                    : Qt.rgba(0.74, 0.74, 0.74, 0.18)
            border.width: 1

            // Password bullet dots
            Row {
                anchors.left:           parent.left
                anchors.leftMargin:     16
                anchors.verticalCenter: parent.verticalCenter
                spacing:                5
                clip:                   true

                Repeater {
                    model: Math.min(passwordField.text.length, 22)
                    Rectangle {
                        width:  7
                        height: 7
                        radius: 3.5
                        color:  root.loginFailed ? root.clrError : root.clrFg
                    }
                }
            }

            // Transparent input captures keystrokes; bullets above render visually
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
                focus:               root.currentUser !== ""

                onTextChanged: root.loginFailed = false

                Keys.onReturnPressed: {
                    var user = root.currentUser !== "" ? root.currentUser : userField.text.trim()
                    if (user !== "") {
                        sddm.login(user, passwordField.text, root.sessionIndex)
                    }
                    event.accepted = true
                }
                Keys.onEscapePressed: {
                    text = ""
                    root.loginFailed = false
                }
            }
        }
    }

    // Session selector — bottom left
    Row {
        anchors.left:         parent.left
        anchors.bottom:       parent.bottom
        anchors.leftMargin:   52
        anchors.bottomMargin: 44
        spacing: 10
        verticalItemAlignment: Row.AlignVCenter

        Text {
            text:  "‹"
            color: prevArea.containsMouse ? root.clrFg : root.clrDim
            font.family:    "JetBrains Mono"
            font.pixelSize: 13

            MouseArea {
                id:            prevArea
                anchors.fill:  parent
                hoverEnabled:  true
                onClicked: {
                    var count = sessionModel.rowCount()
                    root.sessionIndex = (root.sessionIndex - 1 + count) % count
                }
            }
        }

        Text {
            text:  sessionModel.data(sessionModel.index(root.sessionIndex, 0), Qt.DisplayRole) || ""
            color: root.clrDim
            font.family:     "JetBrains Mono"
            font.pixelSize:  13
            font.letterSpacing: 1
        }

        Text {
            text:  "›"
            color: nextArea.containsMouse ? root.clrFg : root.clrDim
            font.family:    "JetBrains Mono"
            font.pixelSize: 13

            MouseArea {
                id:            nextArea
                anchors.fill:  parent
                hoverEnabled:  true
                onClicked: {
                    root.sessionIndex = (root.sessionIndex + 1) % sessionModel.rowCount()
                }
            }
        }
    }

    Component.onCompleted: {
        if (root.currentUser !== "") {
            passwordField.forceActiveFocus()
        } else {
            userField.forceActiveFocus()
        }
    }
}
