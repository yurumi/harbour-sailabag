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
        PropertyChanges { target: backRect; visible: true }
        PropertyChanges { target: shareArticleRect; y: root.height - shareArticleRect.height }
    },
    State {
        name: "visibleWithComment"
        PropertyChanges { target: backRect; visible: true }
        PropertyChanges { target: shareArticleRect; y: root.height - shareArticleRect.height - commentTF.height}
    },
    State {
        name: "invisible"
        PropertyChanges { target: backRect; visible: false }
        PropertyChanges { target: shareArticleRect; y: root.height }
    }
    ]

    transitions: Transition {
        from: "invisible"; to: "visible"; reversible: true
        NumberAnimation { properties: "y"; duration: 400; easing.type: Easing.InOutQuad }
        NumberAnimation { properties: "opacity"; duration: 400; easing.type: Easing.InOutQuad }
    }
    
    Rectangle {
        id: backRect
        anchors.fill: parent
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
        id: shareArticleRect
        width: parent.width
        height: 200
        x: 0
        y: parent.height
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
            font.bold: true
            font.pixelSize: Theme.fontSizeLarge
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }
        }

        Row {
            spacing: 10
            anchors {
                top: headerLBL.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge         
            }
            Button {
                text: qsTr("E-Mail")
                onClicked: {
                    root.state = "visibleWithComment"
                }
            }
            Button {
                text: qsTr("Clipboard")
                onClicked: {
                    Clipboard.text = root.articleURL
                    root.state = "invisible"
                    mainwindow.pushNotification("INFO", qsTr("URL copied to clipboard"), qsTr(""))
                }
            }
        }      
    }

    Rectangle {
        id: commentRect
        color: Qt.rgba(shareArticleRect.color.r - 0.1, shareArticleRect.color.g - 0.1, shareArticleRect.color.b - 0.1, 1.0)
        anchors {
            top: shareArticleRect.bottom
            left: parent.left
            right: parent.right
        }
        height: 100

        Row {
            anchors {
                fill: parent
                margins: Theme.paddingLarge
                rightMargin: 40
            }

            TextField {
                id: commentTF
                width: parent.width - emailSendButton.width 
                placeholderText: qsTr("Enter comment (optional)")
            }

            Rectangle{
                width: 100
                height: 60
                color: shareArticleRect.color
                // anchors {
                //     rightMargin: 20 
                // }
                
                IconButton {
                    id: emailSendButton
                    icon.source: "image://theme/icon-m-enter-next"
                    anchors.centerIn: parent
                    onClicked: {
                        Qt.openUrlExternally("mailto:" + "?subject=" + settings.userName + " shared an article with you from wallabag"
                        + "&body=" + commentTF.text + " " + root.articleURL)
                        root.state = "invisible"
                    }
                }
            }
        } // Row
    } // commentRect
}
