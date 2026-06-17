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

    // Background
    Image {
        anchors.fill: parent
        source:       config.background ? config.background : ""
        fillMode:     Image.PreserveAspectCrop
        cache:        false
    }

    Rectangle {
        anchors.fill: parent
        color:        Qt.rgba(0.071, 0.071, 0.071, 0.65)
    }

    // Time — top right, dim
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

    // Centre: username on top, password below — same position as lock screen
    Column {
        anchors.horizontalCenter:     parent.horizontalCenter
        anchors.verticalCenter:       parent.verticalCenter
        anchors.verticalCenterOffset: 66
        spacing: 10

        // Username field
        Rectangle {
            width:  280
            height: 44
            color:  Qt.rgba(0.65, 0.65, 0.65, 0.28)
            border.color: userField.activeFocus
                ? root.clrAccent
                : Qt.rgba(0.74, 0.74, 0.74, 0.18)
            border.width: userField.activeFocus ? 2 : 1

            Text {
                anchors.left:           parent.left
                anchors.leftMargin:     16
                anchors.verticalCenter: parent.verticalCenter
                visible:                userField.text.length === 0
                text:                   "username"
                color:                  Qt.rgba(0.74, 0.74, 0.74, 0.45)
                font.family:            "JetBrains Mono"
                font.pixelSize:         14
                font.letterSpacing:     1
            }

            TextInput {
                id: userField
                anchors.fill:        parent
                anchors.leftMargin:  16
                anchors.rightMargin: 16
                verticalAlignment:   TextInput.AlignVCenter
                text:                root.currentUser
                color:               root.clrFg
                selectionColor:      "#515151"
                selectedTextColor:   root.clrFg
                font.family:         "JetBrains Mono"
                font.pixelSize:      14
                font.letterSpacing:  1
                clip:                true
                focus:               root.currentUser === ""

                Keys.onTabPressed:    passwordField.forceActiveFocus()
                Keys.onReturnPressed: passwordField.forceActiveFocus()
            }
        }

        // Password field
        Rectangle {
            width:  280
            height: 44
            color:  Qt.rgba(0.65, 0.65, 0.65, 0.28)
            border.color: root.loginFailed
                ? root.clrError
                : passwordField.activeFocus
                    ? root.clrAccent
                    : Qt.rgba(0.74, 0.74, 0.74, 0.18)
            border.width: (passwordField.activeFocus || root.loginFailed) ? 2 : 1

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
                        color:  root.loginFailed ? root.clrError : root.clrFg
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
                focus:               root.currentUser !== ""

                onTextChanged: root.loginFailed = false

                Keys.onReturnPressed: {
                    var user = userField.text.trim()
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

        Text {
            visible:                  root.loginFailed
            anchors.horizontalCenter: parent.horizontalCenter
            text:                     "incorrect password"
            color:                    root.clrError
            font.family:              "JetBrains Mono"
            font.pixelSize:           11
            font.letterSpacing:       1
            opacity:                  0.8
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
                id:           prevArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    var count = sessionModel.rowCount()
                    root.sessionIndex = (root.sessionIndex - 1 + count) % count
                }
            }
        }

        Text {
            text:               sessionModel.data(sessionModel.index(root.sessionIndex, 0), Qt.DisplayRole) || ""
            color:              root.clrDim
            font.family:        "JetBrains Mono"
            font.pixelSize:     13
            font.letterSpacing: 1
        }

        Text {
            text:  "›"
            color: nextArea.containsMouse ? root.clrFg : root.clrDim
            font.family:    "JetBrains Mono"
            font.pixelSize: 13

            MouseArea {
                id:           nextArea
                anchors.fill: parent
                hoverEnabled: true
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
