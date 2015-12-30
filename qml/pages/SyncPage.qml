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

    property ArticlesModel syncModel: ArticlesModel { }
    property bool commitMutex: true

    function getCommitLock()
    {
        if(commitMutex){
            commitMutex = false
            return true
        }else{
            return false
        }
    }

    function releaseCommitLock(){
        commitMutex = true
    }
    
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
                anchors.verticalCenter: sectionLBL.verticalCenter
            }

            Label {
                id: sectionLBL
                text: {
                    switch(section){
                        case "delete":
                        return qsTr("Staged for deletion")
                        case "archive":
                        return qsTr("Staged for archiving")
                        case "unarchive":
                        return qsTr("Staged for unread")
                        case "toggle_fav":
                        return qsTr("Staged for toggle favorite")
                    }
                }
                anchors{
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
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

        section.property: "syncAction"
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
            id: articleDelegate
            
            RemorseItem {
                id: remorse
                onCanceled: releaseCommitLock()
            }
            
            function showRemorseItem(remorseText, func) {
                remorse.execute(articleDelegate, remorseText, func, 1000)
            }
            
            function commit() {
                var serverurl = mainwindow.settings.serverURL
                var username = mainwindow.settings.userName
                var password = mainwindow.settings.userPassword
                
                if ( (serverurl === "") || (username === "") || (password === "") ){
                    mainwindow.pushNotification("INFO", qsTr("Login information incomplete"), qsTr("Check settings page."))    
                }else{
                    var lock = getCommitLock()

                    if(lock){                    
                        // Store ID before index becomes invalid
                        var _id = id
                        
                        if(syncAction==="delete"){
                            showRemorseItem(qsTr("Commit deletion"), function(){
                                pageStack.push(Qt.resolvedUrl("ServerInteractionPage.qml"), {
                                    "action": "delete",
                                    "serverurl": serverurl,
                                    "username": username,
                                    "password": password,
                                    "delID": _id})
                                    
                                syncListView.model.remove(index)
                                ArticlesDatabase.removeID(_id)
                                releaseCommitLock()
                            })
                        }
                        else if(syncAction==="archive"){               
                            showRemorseItem(qsTr("Commit archiving"), function() {
                                pageStack.push(Qt.resolvedUrl("ServerInteractionPage.qml"), {
                                    "action": "toggle_archive",
                                    "serverurl": serverurl,
                                    "username": username,
                                    "password": password,
                                    "delID": _id})
                                        
                                syncListView.model.remove(index)
                                ArticlesDatabase.removeID(_id)
                                releaseCommitLock()
                            })
                        }
                        else if(syncAction==="unarchive"){               
                            showRemorseItem(qsTr("Commit mark as unread"), function() {
                                pageStack.push(Qt.resolvedUrl("ServerInteractionPage.qml"), {
                                    "action": "toggle_archive",
                                    "serverurl": serverurl,
                                    "username": username,
                                    "password": password,
                                    "delID": _id})
                                        
                                syncListView.model.remove(index)
                                ArticlesDatabase.removeID(_id)
                                releaseCommitLock()
                            })
                        }
                        else if(syncAction==="toggle_fav"){
                            var _id = id
                            showRemorseItem(qsTr("Commit toggle favorite"), function() {
                                pageStack.push(Qt.resolvedUrl("ServerInteractionPage.qml"), {
                                    "action": "toggle_fav",
                                    "serverurl": serverurl,
                                    "username": username,
                                    "password": password,
                                    "delID": _id})
                                        
                                syncListView.model.remove(index)
                                ArticlesDatabase.undoSyncStage(_id)
                                // ArticlesDatabase.removeID(_id)
                                releaseCommitLock()
                            })
                        }
                    }else{
                        mainwindow.pushNotification("INFO", qsTr("Please wait"), qsTr("No parallel commits allowed."))    
                    }
                }
            }

            function undoSyncStage() {
                remorseAction(qsTr("Undo"), function() {
                    ArticlesDatabase.undoSyncStage(id)
                    syncListView.model.remove(index)
                }, 2000)
            }

            onClicked: commit()

            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: qsTr("Undo")
                        onClicked: undoSyncStage()
                    }
                }
            }

        }
        
    } // ListView
}
