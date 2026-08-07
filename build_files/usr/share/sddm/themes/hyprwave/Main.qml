import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.bgColor || "#15052e"

    // ---- theme palette (from theme.conf, with safe fallbacks) ----
    readonly property color cBg:     config.bgColor || "#15052e"
    readonly property color cFg:     config.fgColor || "#e0e0ff"
    readonly property color cPink:   config.pink    || "#ff2d95"
    readonly property color cCyan:   config.cyan    || "#00f0ff"
    readonly property color cPurple: config.purple  || "#b967ff"
    readonly property string mono:   config.fontFamily || "JetBrains Mono"

    property int sessionIndex: sessionModel.lastIndex

    // ---------------- Background ----------------
    Image {
        anchors.fill: parent
        source: config.background || ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
    }
    // darken for legibility + subtle purple vignette
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.08, 0.02, 0.18, 0.55) }
            GradientStop { position: 0.6; color: Qt.rgba(0.08, 0.02, 0.18, 0.35) }
            GradientStop { position: 1.0; color: Qt.rgba(0.08, 0.02, 0.18, 0.70) }
        }
    }

    // ---------------- Clock (top-right) ----------------
    Column {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 40
        spacing: 2
        Text {
            id: clock
            horizontalAlignment: Text.AlignRight
            anchors.right: parent.right
            color: cCyan
            font.family: mono
            font.pixelSize: 42
            font.bold: true
            text: Qt.formatTime(new Date(), "HH:mm")
        }
        Text {
            anchors.right: parent.right
            color: cFg
            opacity: 0.7
            font.family: mono
            font.pixelSize: 16
            text: Qt.formatDate(new Date(), "ddd dd MMM yyyy").toUpperCase()
        }
        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: {
                clock.text = Qt.formatTime(new Date(), "HH:mm")
            }
        }
    }

    // ---------------- Title (arcade chromatic neon) ----------------
    Item {
        id: title
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.16
        width: titleFg.width
        height: titleFg.height

        Text {  // cyan ghost (left)
            x: -4; y: 0
            text: "HYPRWAVE"; font.family: mono; font.bold: true
            font.pixelSize: 84; font.letterSpacing: 14
            color: cCyan; opacity: 0.85
        }
        Text {  // pink ghost (right)
            x: 4; y: 0
            text: "HYPRWAVE"; font.family: mono; font.bold: true
            font.pixelSize: 84; font.letterSpacing: 14
            color: cPink; opacity: 0.85
        }
        Text {  // bright core
            id: titleFg
            text: "HYPRWAVE"; font.family: mono; font.bold: true
            font.pixelSize: 84; font.letterSpacing: 14
            color: cFg
        }
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: title.bottom
        anchors.topMargin: 10
        text: "◄ INSERT CREDENTIALS TO CONTINUE ►"
        color: cPurple
        font.family: mono
        font.pixelSize: 16
        font.letterSpacing: 6
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 0.35; duration: 900 }
            NumberAnimation { from: 0.35; to: 1.0; duration: 900 }
        }
    }

    // ---------------- Login panel ----------------
    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: 460
        height: col.implicitHeight + 64
        color: Qt.rgba(0.08, 0.02, 0.18, 0.80)
        border.color: cPink
        border.width: 2
        radius: 0

        // inner cyan frame for the 8-bit double-border look
        Rectangle {
            anchors.fill: parent
            anchors.margins: 5
            color: "transparent"
            border.color: cCyan
            border.width: 1
            radius: 0
        }

        ColumnLayout {
            id: col
            anchors.centerIn: parent
            width: parent.width - 64
            spacing: 16

            // --- USER ---
            Text {
                text: "USER"; color: cCyan; font.family: mono
                font.pixelSize: 13; font.letterSpacing: 3
            }
            ComboBox {
                id: userBox
                Layout.fillWidth: true
                model: userModel
                textRole: "name"
                currentIndex: userModel.lastIndex
                font.family: mono
                font.pixelSize: 16

                contentItem: Text {
                    leftPadding: 12
                    text: userBox.displayText
                    color: cFg
                    font: userBox.font
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    implicitHeight: 44
                    color: Qt.rgba(0, 0, 0, 0.35)
                    border.color: userBox.activeFocus ? cPink : cPurple
                    border.width: 2
                    radius: 0
                }
                indicator: Text {
                    x: userBox.width - width - 12
                    y: (userBox.height - height) / 2
                    text: "▼"; color: cCyan; font.pixelSize: 12
                }
                delegate: ItemDelegate {
                    width: userBox.width
                    contentItem: Text {
                        text: model.name
                        color: cFg; font.family: mono; font.pixelSize: 15
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: highlighted ? Qt.rgba(1, 0.18, 0.58, 0.30) : Qt.rgba(0.08, 0.02, 0.18, 0.95)
                    }
                }
            }

            // --- PASSWORD ---
            Text {
                text: "PASSWORD"; color: cCyan; font.family: mono
                font.pixelSize: 13; font.letterSpacing: 3
            }
            TextField {
                id: pw
                Layout.fillWidth: true
                echoMode: TextInput.Password
                passwordCharacter: "█"
                font.family: mono
                font.pixelSize: 16
                color: cFg
                placeholderText: "••••••••"
                placeholderTextColor: Qt.rgba(0.88, 0.88, 1, 0.3)
                selectByMouse: true
                leftPadding: 12
                background: Rectangle {
                    implicitHeight: 44
                    color: Qt.rgba(0, 0, 0, 0.35)
                    border.color: pw.activeFocus ? cPink : cPurple
                    border.width: 2
                    radius: 0
                }
                onAccepted: doLogin()
                Keys.onReturnPressed: doLogin()
                Keys.onEnterPressed: doLogin()
            }

            // --- message line ---
            Text {
                id: msg
                Layout.fillWidth: true
                text: " "
                color: cPink
                font.family: mono
                font.pixelSize: 13
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            // --- LOGIN button ---
            Button {
                id: loginBtn
                Layout.fillWidth: true
                text: "▶ START"
                font.family: mono
                font.pixelSize: 18
                font.bold: true
                font.letterSpacing: 4
                contentItem: Text {
                    text: loginBtn.text
                    color: loginBtn.down ? cBg : cBg
                    font: loginBtn.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    implicitHeight: 48
                    color: loginBtn.down ? cCyan : cPink
                    border.color: cCyan
                    border.width: 2
                    radius: 0
                }
                onClicked: doLogin()
            }

            // --- session selector ---
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                Text {
                    text: "SESSION"; color: cPurple; font.family: mono
                    font.pixelSize: 12; font.letterSpacing: 2
                }
                Item { Layout.fillWidth: true }
                ComboBox {
                    id: sessionBox
                    Layout.preferredWidth: 220
                    model: sessionModel
                    textRole: "name"
                    currentIndex: sessionModel.lastIndex
                    onActivated: root.sessionIndex = currentIndex
                    font.family: mono
                    font.pixelSize: 13
                    contentItem: Text {
                        leftPadding: 8
                        text: sessionBox.displayText
                        color: cFg; font: sessionBox.font
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        implicitHeight: 32
                        color: Qt.rgba(0, 0, 0, 0.35)
                        border.color: cPurple; border.width: 1; radius: 0
                    }
                    indicator: Text {
                        x: sessionBox.width - width - 8
                        y: (sessionBox.height - height) / 2
                        text: "▼"; color: cCyan; font.pixelSize: 10
                    }
                    delegate: ItemDelegate {
                        width: sessionBox.width
                        contentItem: Text {
                            text: model.name; color: cFg
                            font.family: mono; font.pixelSize: 13
                        }
                        background: Rectangle {
                            color: highlighted ? Qt.rgba(1, 0.18, 0.58, 0.30) : Qt.rgba(0.08, 0.02, 0.18, 0.95)
                        }
                    }
                }
            }
        }
    }

    // ---------------- Power controls (bottom-right) ----------------
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 36
        spacing: 22

        Repeater {
            model: [
                { label: "SHUTDOWN", act: "off" },
                { label: "REBOOT",   act: "reboot" },
                { label: "SUSPEND",  act: "suspend" }
            ]
            delegate: Text {
                required property var modelData
                text: modelData.label
                color: hov.hovered ? cPink : cFg
                opacity: hov.hovered ? 1.0 : 0.6
                font.family: mono
                font.pixelSize: 13
                font.letterSpacing: 2
                HoverHandler { id: hov }
                TapHandler {
                    onTapped: {
                        if (modelData.act === "off") sddm.powerOff()
                        else if (modelData.act === "reboot") sddm.reboot()
                        else sddm.suspend()
                    }
                }
            }
        }
    }

    // ---------------- login plumbing ----------------
    function doLogin() {
        msg.text = "AUTHENTICATING…"
        msg.color = cCyan
        sddm.login(userBox.currentText, pw.text, root.sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginSucceeded() {
            msg.color = cCyan
            msg.text = "ACCESS GRANTED"
        }
        function onLoginFailed() {
            msg.color = cPink
            msg.text = "ACCESS DENIED — TRY AGAIN"
            pw.text = ""
            pw.forceActiveFocus()
        }
        function onInformationMessage(message) {
            msg.color = cPurple
            msg.text = message
        }
    }

    Component.onCompleted: {
        if (userBox.currentText.length > 0)
            pw.forceActiveFocus()
        else
            userBox.forceActiveFocus()
    }
}
