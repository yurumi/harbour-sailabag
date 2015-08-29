import QtQuick 2.0
import QtWebKit 3.0
import Sailfish.Silica 1.0


Rectangle {
    id: loadScreen
    anchors.fill: parent
    opacity: 1.0
    visible: opacity > 0.1
    state: "show"

    property alias text: loadScreenText.text
    // property int progress: 0
    
    color: "black"

    states: [
    State {
        name: "show"
        PropertyChanges { target: loadScreen; opacity: 1.0 }
    },
    State {
        name: "hide"
        PropertyChanges { target: loadScreen; opacity: 0.0 }
    }
    ]

    transitions: Transition {
        from: "show"; to: "hide"; reversible: false
        NumberAnimation { properties: "opacity"; duration: 1000; easing.type: Easing.InOutQuad }
    }

    // onProgressChanged: {
    //     console.log("PROGRESS: " + progress)
    // }
    
    Label {
        id: loadScreenText
        text: qsTr("Loading...")
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 150
    }
    
    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: loadScreen.visible
        size: BusyIndicatorSize.Large 
    }

    // Rectangle {
    //     id: progressBarBackground
    //     height: 20
    //     color: "blue"
    //     anchors{
    //         left: parent.left
    //         right: parent.right
    //         verticalCenter: parent.verticalCenter
    //         margins: Theme.paddingLarge
    //     }
        
    // }
}
