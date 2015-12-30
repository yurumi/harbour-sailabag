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

import QtQuick 2.1
import Sailfish.Silica 1.0

import "../js/articles/ArticlesDatabase.js" as ArticlesDatabase

Page {
    id: versionUpdateInfoPage

    SilicaFlickable {
        id: versionUpdateInfoFlickable
        anchors.fill: parent
        contentHeight: contentColumn.height

        VerticalScrollDecorator { flickable: versionUpdateInfoFlickable }

        Column {
            id: contentColumn
            width: parent.width
            spacing: 10

            Label {
                id: versionUpdateInfoHeading
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Theme.paddingLarge
                text: qsTr("Old version of articles database found.") //+ "\n" +
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                font.bold: true
                font.pixelSize: Theme.fontSizeLarge
            }

            Label {
                anchors.left: versionUpdateInfoHeading.left
                anchors.right: versionUpdateInfoHeading.right
                text: qsTr("You have two possibilities: Either choose '" + 
                deleteButton.text + "' and download articles again or choose '" + updateButton.text + "' to update the current database. If you encounter problems, go to the settings page, clear local database and re-download articles.")               
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
            }

            Button {
                id: deleteButton
                text: qsTr("Delete local database")
                anchors.left: versionUpdateInfoHeading.left
                anchors.right: versionUpdateInfoHeading.right
                onClicked: {
                    ArticlesDatabase.clear()
                    pageStack.replace(articleOverviewPage)   
                }
            }

            Button {
                id: updateButton
                text: qsTr("Update local database")
                anchors.left: versionUpdateInfoHeading.left
                anchors.right: versionUpdateInfoHeading.right
                onClicked: {
                    ArticlesDatabase.updateDbSchema()
                    pageStack.replace(articleOverviewPage)
                }
            }
            
            Rectangle {
                width: parent.width
                height: 30
                color: "transparent"
            }

            Label {
                id: changeLogHeading
                anchors.left: versionUpdateInfoHeading.left
                anchors.right: versionUpdateInfoHeading.right
                text: qsTr("Changelog:") //+ "\n" +
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
                font.bold: true
            }

            Label {
                anchors.left: versionUpdateInfoHeading.left
                anchors.right: versionUpdateInfoHeading.right
                text: "[v1.5]\n- Added archived articles page\n- Added favorite articles page\n- Update path for new database schemata\n- Icons for favorite/archived articles\n\n[v1.1]\n- Share articles via e-mail\n- Copy article URL to clipboard to share it e.g. with threema\n- Active cover added (download articles, bag clipboard)\n- Fixed issue #12 (delete/archive multiple items in a row)\n- Archive/delete/share from inside article view\n- Added german translation\n\n[v1.0]\n- improved look & feel\n- new icon\n- no issues from early users --> V 1.0!\n\n[v0.9]\n- Initial harbour version"
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
            }

            Rectangle {
                width: parent.width
                height: 30
                color: "transparent"
            }

            Label {
                id: statisticsHeading
                anchors.left: versionUpdateInfoHeading.left
                anchors.right: versionUpdateInfoHeading.right
                text: qsTr("Statistics (12/28/2015):") //+ "\n" +
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
                font.bold: true
            }

            Label {
                anchors.left: versionUpdateInfoHeading.left
                anchors.right: versionUpdateInfoHeading.right
                text: "Total downloads: 296\nActive installs: 236\nTotal likes: 42\nTotal reviews: 9\nNumber of flattrers: 3 (Thanks!)\nTotal flattred amount: €13.21"
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
            }

        }
        
    }
}
