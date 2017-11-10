import QtQuick 2.3
import AlgWidgets 1.0
import AlgWidgets.Style 1.0

Rectangle {
    property alias text : label.text

    height: 25
    anchors.left: parent.left
    anchors.right: parent.right
    color: "transparent"


    AlgLabel {
        id: label
        font.bold: true
//        text: "Job Name"
    }
    Rectangle {
        height: 2
        color: "grey"
        anchors.leftMargin: 10
        anchors.left: label.right
        anchors.right: parent.right
        anchors.verticalCenter: label.verticalCenter
    }
}