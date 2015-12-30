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
import "../js/articles/ArticlesDatabase.js" as ArticlesDatabase

SilicaListView {
    id: articleListView
    model: unreadArticlesModel
    spacing: 10
    width: view.itemWidth
    height: view.height
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
            onClicked: pageStack.push(Qt.resolvedUrl("../pages/SettingsPage.qml"), { "settings": mainwindow.settings,
            "articlesModel": model})
        }
        MenuItem {
            text: qsTr("Go to sync page")
            onClicked: pageStack.push(Qt.resolvedUrl("../pages/SyncPage.qml"))
        }
        MenuItem {
            text: qsTr("Update unread articles")
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
    }// PullDownMenu

    header: PageHeader {
        title: qsTr("Unread Articles")
    }// PageHeader

    delegate: ArticleDelegate{
        function markAsRead() {
            remorseAction(qsTr("Stage for archiving"), function() {
                ArticlesDatabase.markAsRead(model, url)
                articleListView.model.remove(index)
            }, 2000)
        }
            
        function stageForToggleFavorite() {
            remorseAction(qsTr("Stage for toggle favorite"), function() {
                ArticlesDatabase.stageForToggleFavorite(model, url)
                articleListView.model.remove(index)
            }, 2000)
        }

        function stageForDeletion() {
            remorseAction(qsTr("Stage for deletion"), function() {
                ArticlesDatabase.stageForDeletion(model, url)
                articleListView.model.remove(index)
            }, 2000)
        }

        onClicked: {
            pageStack.push(Qt.resolvedUrl("../pages/ArticleViewPage.qml"), {"articleUrl": url, "articleTitle": title, "articleContent": content, "articlesModel": model})
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
                    text: qsTr("Stage for toggle favorite")
                    onClicked: stageForToggleFavorite()
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

    }// ArticleDelegate

    VerticalScrollDecorator {}

    Rectangle {
        id: leftTabIndicator
        x: -width / 2
        y: 40
        width: 20
        height: 20
        color: Theme.highlightColor
        opacity: 0.3
    }

} // SilicaListView
