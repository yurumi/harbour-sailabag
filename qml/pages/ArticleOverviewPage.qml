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
    
    property ArticlesModel unreadArticlesModel: ArticlesModel { }
    property ArticlesModel favoriteArticlesModel: ArticlesModel { }
    property ArticlesModel archivedArticlesModel: ArticlesModel { }

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
    
    function updateModels()
    {
        ArticlesDatabase.removeInvalidEntries()
        ArticlesDatabase.queryUnreadArticles(unreadArticlesModel)
        ArticlesDatabase.queryFavoriteArticles(favoriteArticlesModel)
        ArticlesDatabase.queryArchivedArticles(archivedArticlesModel)
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
        updateModels()
        state = "idle"
    }

    Component.onCompleted: {
        mainwindow.downloadActive.connect(downloadActive)
        mainwindow.downloadError.connect(downloadError)
        mainwindow.downloadFinished.connect(downloadFinished)
        updateModels()
    }

    onStatusChanged: {
        if(status === PageStatus.Activating){
            updateModels()
        }
    }

    SlideshowView {
        id: view
        width: parent.width
        height: parent.height
        itemWidth: width
        itemHeight: height
        
        model: ListModel {
            id: articleCategoryModel
            ListElement { articleCategory: "unread" }
            ListElement { articleCategory: "favorite" }
            ListElement { articleCategory: "archived" }
        }
        delegate: Loader {
            id: delegateLoader
            source: {
                if(articleCategory === "unread"){
                    return "../components/UnreadArticlesDelegate.qml"
                }
                else if(articleCategory === "favorite"){
                    return "../components/FavoriteArticlesDelegate.qml"
                }
                else if(articleCategory === "archived"){
                    return "../components/ArchivedArticlesDelegate.qml"
                }
            }
        }
    } // SlideshowView

    ShareArticle { id: shareArticle;}
    
    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: false
        size: BusyIndicatorSize.Large 
    }
}
