
import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import AlgWidgets 1.0
import "deadline.js" as Deadline

AlgDialog {
    id: configureDialog
    visible: false
    title: "configure"
    width: 500
    minimumWidth: width
    maximumWidth: width
    height: 150
    minimumHeight: height
    maximumHeight: height

    onAccepted: {
        internal.save()
    }

    QtObject {
        id: internal

        function save() {
            alg.settings.setValue("Host", hostTextEdit.text)
            alg.settings.setValue("Port", portTextEdit.text)
            alg.settings.setValue("User", usernameTextEdit.text)
        }

        function testConnection() {
            testButton.enabled = false
            Deadline.getUser(usernameTextEdit.text, onSuccess, onError)
        }

        function onSuccess(user) {
            if (user.length == 0) {
                messageDialog.title = "Warning"
                messageDialog.text = "Connection to deadline was successful, but no such user found"
                messageDialog.icon = StandardIcon.Warning
            } else {
                messageDialog.title = "Success"
                messageDialog.text = "Connection to deadline was successful, user found"
                messageDialog.icon = StandardIcon.Information
            }
            messageDialog.open()
            testButton.enabled = true
        }

        function onError() {
            messageDialog.title = "Error"
            messageDialog.text = "Connection to deadline was not successful"
            messageDialog.icon = StandardIcon.Critical
            messageDialog.open()
            testButton.enabled = true
        }

    }

    Rectangle {
        id: content
        parent: contentItem
        anchors.fill: parent
        anchors.margins: 12
        color: "transparent"
        clip: true

        GridLayout {
            columns: 2
            anchors {
                top: parent.top
                right: parent.right
                left: parent.left
            }

            AlgLabel { text: "Host" }
            AlgTextEdit {
                id: hostTextEdit
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                text: alg.settings.value("Host", "")
            }

            AlgLabel { text: "Port" }
            AlgTextEdit {
                id: portTextEdit
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                text: alg.settings.value("Port", "")
            }

            AlgLabel { text: "Deadline username" }
            AlgTextEdit {
                id: usernameTextEdit
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                text: alg.settings.value("User", "")
            }

            AlgButton {
                id: testButton
                Layout.row: 3
                Layout.column: 1
                text: "Test connection"
                anchors {
                    right: parent.right
                }
                onClicked: {
                    internal.save()
                    internal.testConnection()
                }
            }
        }
    }

    MessageDialog {
        id: messageDialog
        visible: false
    }


}
