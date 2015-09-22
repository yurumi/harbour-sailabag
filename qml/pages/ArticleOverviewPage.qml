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
    state: "idle"
    
    property ArticlesModel articlesModel: ArticlesModel { }

    states: [
    State {
        name: "idle"
        PropertyChanges { target: busyIndicator; running: false }
        PropertyChanges { target: busyIndicator; visible: false }
    },
    State {
        name: "busy"
        PropertyChanges { target: busyIndicator; running: true }
        PropertyChanges { target: busyIndicator; visible: true }
    }
    ]
    
    function updateModel()
    {
        ArticlesDatabase.removeInvalidEntries()
        ArticlesDatabase.queryUnreadArticles(articlesModel)
    }

    function downloadActive()
    {
        state = "busy"
    }

    function downloadError()
    {
        state = "idle"
    }

    function downloadFinished()
    {
        updateModel()
        state = "idle"
    }

    Component.onCompleted: {
        mainwindow.downloadActive.connect(downloadActive)
        mainwindow.downloadError.connect(downloadError)
        mainwindow.downloadFinished.connect(downloadFinished)
        updateModel()
    }

    onStatusChanged: {
        if(status === PageStatus.Activating){
            updateModel()
        }
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
                onClicked: pageStack.push(Qt.resolvedUrl("SyncPage.qml"))
            }
            MenuItem {
                text: qsTr("Download articles")
                onClicked: {
                    mainwindow.downloadUnreadArticles()
                }
            }
            MenuItem {
                text: qsTr("Bag clipboard!")
                onClicked: {
                    mainwindow.sendClipboard()
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
                    articleListView.model.remove(index)
                }, 2000)
            }
    
            function stageForDeletion() {
                remorseAction(qsTr("Stage for deletion"), function() {
                    ArticlesDatabase.stageForDeletion(articlesModel, url)
                    articleListView.model.remove(index)
                }, 2000)
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("ArticleViewPage.qml"), {"articleUrl": url, "articleTitle": title, "articleContent": content, "articlesModel": articlesModel})
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
                    MenuItem {
                        text: qsTr("Share")
                        onClicked: {
                            shareArticle.articleURL = url
                            shareArticle.state = "visible"
                        }
                    }       
                }
            } // contextMenu

        }
        
        VerticalScrollDecorator {}

    } // ListView

    ShareArticle { id: shareArticle;}
    
    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: false
        size: BusyIndicatorSize.Large 
    }
}
