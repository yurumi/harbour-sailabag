import QtQuick 2.0
import QtWebKit 3.0
import Sailfish.Silica 1.0


Rectangle {
    id: loadScreen
    anchors.fill: parent

    property alias text: loadScreenText.text
    
    color: "black"

    Label {
        id: loadScreenText
        text: qsTr("Committing...")
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 150
    }
    
    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: loadScreen.visible
        size: BusyIndicatorSize.Large 
    }

}
