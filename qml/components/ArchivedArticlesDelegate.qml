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
    model: archivedArticlesModel
    spacing: 10
    width: view.itemWidth
    height: view.height
    opacity: busyIndicator.running ? 0.5 : 1.0

    Behavior on opacity {
        NumberAnimation { duration: 300 }
    }

    ViewPlaceholder {
        enabled: (articleListView.count === 0) && (busyIndicator.running === false)
        text: qsTr("Pull down to synchronize.")
    }

    PullDownMenu {
        MenuItem {
            text: qsTr("Update archived articles")
            onClicked: {
                mainwindow.downloadArchivedArticles()
            }
        }
    }// PullDownMenu

    header: PageHeader {
        title: qsTr("Archived Articles")
    }// PageHeader

    delegate: ArticleDelegate{
        function markAsUnread() {
            remorseAction(qsTr("Stage for mark as unread"), function() {
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
                    text: qsTr("Stage for mark as unread")
                    onClicked: markAsUnread()
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
