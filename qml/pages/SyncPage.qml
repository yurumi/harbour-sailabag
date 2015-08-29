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

import "../models"
import "../components"
import "../js/articles/ArticlesDatabase.js" as ArticlesDatabase

Page {
    id: syncpage

    property SyncModel syncModel: SyncModel { }
    property variant unreadArticlesModel: null

    function updateModel()
    {
        ArticlesDatabase.queryStagedArticles(syncModel)
    }
    
    Component.onCompleted: {
        updateModel();
    }

    Component {
        id: sectionHeading

        Item {
            width: parent.width
            height: 75
            
            Rectangle {
                width: parent.width
                height: sectionLBL.height
                color: Theme.secondaryColor
                opacity: 0.1
                // anchors.horizontalCenter: sectionLBL.horizontalCenter
                anchors.verticalCenter: sectionLBL.verticalCenter
            }

            Label {
                id: sectionLBL
                text: section == "delete" ? qsTr("Staged for Deletion") : qsTr("Staged for archiving")
                anchors{
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    // margins: Theme.paddingLarge
                }
                // font.bold: true
                color: Theme.highlightColor
                // color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                font.pixelSize: Theme.fontSizeMedium
            }
        }
    }
    
    SilicaListView {
        id: syncListView
        anchors.fill: parent
        model: syncModel
        spacing: 10

        section.property: "sectionString"
        section.criteria: ViewSection.FullString
        section.delegate: sectionHeading

        ViewPlaceholder {
            enabled: (syncListView.count === 0) //&& (busyIndicator.running === false)
            text: qsTr("No articles marked for deletion or marked as read.")
        }

        // PullDownMenu {
        //     MenuItem {
        //         text: qsTr("Synchronize all")
        //         onClicked: pageStack.push(Qt.resolvedUrl("SyncPage.qml"))
        //     }
        // }

        header: PageHeader {
            title: qsTr("Sync Overview")
        }

        delegate: ArticleDelegate{
            // menu: contextMenuSync

            function commit() {
                var serverurl = mainwindow.settings.serverURL
                var username = mainwindow.settings.userName
                var password = mainwindow.settings.userPassword
                
                if ( (serverurl === "") || (username === "") || (password === "") ){
                    mainwindow.pushNotification("INFO", qsTr("Login information incomplete"), qsTr("Check settings page."))    
                }else{
                    // Store ID before index becomes invalid
                    var _id = id
                                                        
                    if(deletionFlag){               
                        remorseAction("Commit deletion", function() {
                            pageStack.push(Qt.resolvedUrl("DeleteArticlePage.qml"), {
                                "action": "delete",
                                "serverurl": serverurl,
                                "username": username,
                                "password": password,
                                "delID": _id})
                                
                                syncListView.model.remove(index)
                                ArticlesDatabase.removeID(_id)
                        }, 1000)
                    }
                    else{               
                        remorseAction("Commit archiving", function() {
                            pageStack.push(Qt.resolvedUrl("DeleteArticlePage.qml"), {
                                "action": "toggle_archive",
                                "serverurl": serverurl,
                                "username": username,
                                "password": password,
                                "delID": _id})
                                
                                syncListView.model.remove(index)
                                ArticlesDatabase.removeID(_id)
                        }, 1000)
                    }
                }
            }

            function markAsUnread() {
                remorseAction(qsTr("Mark as unread"), function() {
                    ArticlesDatabase.markAsUnread(syncModel, unreadArticlesModel, id)
                }, 2000)
            }

            onClicked: commit()

            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: "Mark as unread"
                        onClicked: markAsUnread()
                    }
                }
            }

        }
        
    } // ListView
}
