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

Item {
    id: root
    property string articleURL: ""
    anchors.fill: parent
    state: "invisible"

    states: [
    State {
        name: "visible"
        PropertyChanges { target: root; visible: true }
    },
    State {
        name: "invisible"
        PropertyChanges { target: root; visible: false }
    }
    ]

    // transitions: Transition {
    //     from: "show"; to: "hide"; reversible: false
    //     NumberAnimation { properties: "opacity"; duration: 1000; easing.type: Easing.InOutQuad }
    // }
    
    Rectangle {
        id: backRect
        anchors {
            top: parent.top
            bottom: shareArticle.top
            left: parent.left
            right: parent.right
        }
        color: "black"
        opacity: 0.5

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.state = "invisible"
            }
        }
    }
    Rectangle {
        id: shareArticle
        // width: parent.width
        height: 200
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        color: Qt.rgba(Theme.secondaryHighlightColor.r, Theme.secondaryHighlightColor.g, Theme.secondaryHighlightColor.b, 1.0) 

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // root.state = "invisible"
            }
        }

        Label {
            id: headerLBL
            text: qsTr("Share article")
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeLarge
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }
        }

        Row {
            anchors {
                top: headerLBL.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge         
            }
            Button {
                text: "E-Mail"
                onClicked: {
                    Qt.openUrlExternally("mailto:" + "?subject=Somebody shared an article with you from wallabag" + "&body=" + root.articleURL)
                    root.state = "invisible"
                }
            }
            Button {
                text: "Clipboard"
                onClicked: {
                    Clipboard.text = root.articleURL
                    root.state = "invisible"
                    mainwindow.pushNotification("INFO", qsTr("URL copied to clipboard"), qsTr(""))
                }
            }
        }      
    }
}
