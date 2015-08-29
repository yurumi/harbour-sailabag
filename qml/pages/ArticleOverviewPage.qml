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
    id: articleoverview

    property ArticlesModel articlesModel: ArticlesModel { }

    // property int signInState: -1

    function updateModel()
    {
        ArticlesDatabase.removeInvalidEntries()
        ArticlesDatabase.queryUnreadArticles(articlesModel);
        busyIndicator.running = false
        busyIndicator.visible = false
    }
    
    function downloadError()
    {
        busyIndicator.running = false
        busyIndicator.visible = false
    }

    // function signIn()
    // {
    //     console.log("Signing in...")
    //     mainwindow.downloadmanager.updateSignInState(mainwindow.settings.serverURL)
    //     // pageStack.push(Qt.resolvedUrl("SignInPage.qml"), {"url": mainwindow.settings.serverURL,
    //     //                                                   "username": mainwindow.settings.userName,
    //     //                                                   "password": mainwindow.settings.userPassword}
    //     // )
    // }

    // function storeSignInState(signedIn)
    // {
    //     console.log("SIGNINSTATE: " + signedIn)
    // }
    
    Component.onCompleted: {
        mainwindow.downloadmanager.syncFinished.connect(updateModel);
        mainwindow.downloadmanager.downloadError.connect(downloadError);
        // mainwindow.downloadmanager.signInStateUpdate.connect(storeSignInState);
        updateModel()
    }

    SilicaListView {
        id: articleListView
        anchors.fill: parent
        model: articlesModel
        spacing: 10
        opacity: busyIndicator.running ? 0.5 : 1.0
        
        Behavior on opacity {
                NumberAnimation { duration: 300 }
        }
        
        ViewPlaceholder {
            enabled: (articleListView.count === 0) && (busyIndicator.running === false)
            text: qsTr("Visit settings page then synchronize.")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"), { "settings": mainwindow.settings,
                                                                                "articlesModel": articlesModel})
            }
            MenuItem {
                text: qsTr("Go to sync page")
                onClicked: pageStack.push(Qt.resolvedUrl("SyncPage.qml"), { "unreadArticlesModel": articlesModel})
            }
            MenuItem {
                text: qsTr("Download articles")
                onClicked: {
                    busyIndicator.running = true
                    busyIndicator.visible = true

                    var serverURL = mainwindow.settings.serverURL
                    var userID = mainwindow.settings.userID
                    var userToken = mainwindow.settings.userToken
                    // ArticlesDatabase.clear()
                    ArticlesDatabase.invalidateEntries()
                    mainwindow.downloadmanager.downloadFeed(serverURL, userID, userToken)
                }
            }
            MenuItem {
                text: qsTr("Bag clipboard!")
                onClicked: {
                    if (Clipboard.hasText) {
                        var serverurl = mainwindow.settings.serverURL
                        var username = mainwindow.settings.userName
                        var password = mainwindow.settings.userPassword

                        if ( (serverurl === "") || (username === "") || (password === "") ){
                            mainwindow.pushNotification("INFO", qsTr("Login information incomplete"), qsTr("Check settings page."))    
                        }else{
                            // articleoverview.signIn()
                            pageStack.push(Qt.resolvedUrl("DeleteArticlePage.qml"), {
                                                          "action": "post_article",
                                                          "serverurl": serverurl,
                                                          "username": username,
                                                          "password": password,
                                                          "delID": -1})
                            
                            // pageStack.push(Qt.resolvedUrl("PostArticlePage.qml"), {"serverurl": serverurl,
                            //                                                        "username": username,
                            //                                                        "password": password})
                        }
                    }else{
                        mainwindow.pushNotification("INFO", qsTr("Clipboard is empty"), qsTr("Mark URL to copy to the clipboard."))
                    }           
                }
            }
        }

        header: PageHeader {
            title: qsTr("Unread Articles")
        }

        delegate: ArticleDelegate{
            function markAsRead() {
                remorseAction(qsTr("Stage for archiving"), function() {
                    ArticlesDatabase.markAsRead(articlesModel, url)
                }, 2000)
            }
    
            function stageForDeletion() {
                remorseAction(qsTr("Stage for deletion"), function() {
                    ArticlesDatabase.stageForDeletion(articlesModel, url)
                }, 2000)
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("ArticleViewPage.qml"), {"articleUrl": url, "articleTitle": title, "articleContent": content})
            }
            
            Component {
                id: contextMenu
                
                ContextMenu {
                    MenuItem {
                        text: qsTr("Stage for archiving")
                        onClicked: markAsRead()
                    }
                    MenuItem {
                        text: qsTr("Stage for deletion")
                        onClicked: stageForDeletion()
                    }       
                }
            } // contextMenu

        }
        
        VerticalScrollDecorator {}

    } // ListView

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: false
        size: BusyIndicatorSize.Large 
    }
}
