/*
    Sailabag - A SailfishOS client for wallabag.
    Copyright (C) 2015 Thomas Eigel
    Contact: Thomas Eigel <yurumi@gmx.de>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

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
        text: qsTr("Loading")
        font.family: Theme.fontFamilyHeading
        font.pixelSize: Theme.fontSizeLarge
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -120
    }
    
    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: loadScreen.visible
        size: BusyIndicatorSize.Large 
    }
}
