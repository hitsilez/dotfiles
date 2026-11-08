import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1366
    height: 768
    color: "#080B16"

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("background.jpg")
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.025, 0.035, 0.075, 0.63)
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.02, 0.03, 0.07, 0.22) }
            GradientStop { position: 1.0; color: Qt.rgba(0.02, 0.03, 0.07, 0.70) }
        }
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 82
        anchors.verticalCenter: parent.verticalCenter
        width: 550
        spacing: 12

        Text {
            text: "PERSONAL WORKSPACE"
            color: "#AAB5FF"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            font.letterSpacing: 3
        }

        Text {
            id: clockText
            text: Qt.formatTime(new Date(), "HH:mm")
            color: "#FFFFFF"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 78
            font.weight: Font.Light
        }

        Text {
            id: dateText
            text: Qt.formatDate(new Date(), "dddd, d MMMM yyyy")
            color: "#D0D4E8"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 15
        }

        Rectangle {
            width: 68
            height: 3
            radius: 2
            color: "#8998FF"
        }

        Text {
            text: "A fresh start."
            color: "#FFFFFF"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 33
        }

        Text {
            text: "Your space is ready."
            color: "#C3C8DD"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            clockText.text = Qt.formatTime(new Date(), "HH:mm")
            dateText.text = Qt.formatDate(new Date(), "dddd, d MMMM yyyy")
        }
    }

    Rectangle {
        id: loginCard
        width: 410
        height: 470
        x: root.width - width - 76
        y: (root.height - height) / 2
        radius: 24
        color: Qt.rgba(0.045, 0.06, 0.12, 0.86)
        border.width: 1
        border.color: Qt.rgba(0.58, 0.64, 1.0, 0.52)

        Column {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 10

            Text {
                text: "WELCOME BACK"
                color: "#AAB5FF"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                font.letterSpacing: 2
            }

            Text {
                text: "Sign in"
                color: "#FFFFFF"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 27
            }

            Text {
                text: "Enter your password to continue."
                color: "#AEB5CC"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
            }

            Item { width: 1; height: 4 }

            Text {
                text: "USERNAME"
                color: "#BEC5E6"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
            }

            Rectangle {
                width: parent.width
                height: 48
                radius: 11
                color: "#252B40"
                border.width: 1
                border.color: Qt.rgba(0.55, 0.62, 1.0, 0.35)

                TextInput {
                    id: userEntry
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    text: userModel.lastUser
                    color: "#F5F6FF"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    KeyNavigation.tab: passwordEntry
                }
            }

            Text {
                text: "PASSWORD"
                color: "#BEC5E6"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
            }

            Rectangle {
                width: parent.width
                height: 48
                radius: 11
                color: "#252B40"
                border.width: 1
                border.color: passwordEntry.activeFocus ? "#8998FF" : "#454C68"

                TextInput {
                    id: passwordEntry
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    color: "#FFFFFF"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 15
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    KeyNavigation.backtab: userEntry
                    onAccepted: sddm.login(userEntry.text, passwordEntry.text, sessionPicker.index)
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    visible: passwordEntry.text.length === 0
                    text: "Enter password"
                    color: "#7E879F"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }
            }

            Rectangle {
                width: parent.width
                height: 49
                radius: 12
                color: "#778AFF"

                Text {
                    anchors.centerIn: parent
                    text: "UNLOCK  →"
                    color: "#FFFFFF"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    font.bold: true
                    font.letterSpacing: 1
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.login(userEntry.text, passwordEntry.text, sessionPicker.index)
                }
            }

            Text {
                id: statusText
                width: parent.width
                height: 16
                text: ""
                color: "#FF9CA9"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
            }

            Text {
                text: "DESKTOP SESSION"
                color: "#BEC5E6"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
            }

            ComboBox {
                id: sessionPicker
                width: parent.width
                height: 38
                model: sessionModel
                index: sessionModel.lastIndex
                arrowIcon: Qt.resolvedUrl("angle-down.png")
                font.pixelSize: 12
            }
        }
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            passwordEntry.text = ""
            statusText.text = "Incorrect password. Please try again."
            passwordEntry.forceActiveFocus()
        }

        function onLoginSucceeded() {
            statusText.text = "Signing in..."
        }
    }

    Component.onCompleted: {
        if (userEntry.text.length === 0)
            userEntry.forceActiveFocus()
        else
            passwordEntry.forceActiveFocus()
    }
}
