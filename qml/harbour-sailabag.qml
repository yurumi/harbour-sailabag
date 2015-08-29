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
import Sailfish.Silica 1.0
import "pages"
import harbour.sailabag.notifications 1.0
import harbour.sailabag.DownloadManager 1.0
import "models"
import "pages"
import "js/settings/Database.js" as Database
import "js/articles/ArticlesDatabase.js" as ArticlesDatabase

ApplicationWindow
{
    id: mainwindow
    allowedOrientations: defaultAllowedOrientations

    initialPage: Component { ArticleOverviewPage{} }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    property alias settings: settings
    property alias downloadmanager: downloadmanager

    function store (url, id, title, content, pubDate)
    {
        ArticlesDatabase.store(url, id, title, content, pubDate);
    }

    // function sendClipboard()
    // {
    //     if (Clipboard.hasText) {
    //         pageStack.push(Qt.resolvedUrl("SaveArticlePage.qml"), {"articleURL": Clipboard.text})
    //     }else{
    //         mainwindow.pushNotification("INFO", qsTr("Clipboard is empty"), qsTr("Mark URL to copy to the clipboard."))
    //     }           
    // }

    Settings
    {
        id: settings

        Component.onCompleted: {
            // settings
            Database.load();
            Database.transaction(function(tx) {
                    var serverURL = Database.transactionGet(tx, "serverURL");
                    settings.serverURL = (serverURL === false ? "http:\/\/" : serverURL);

                    var userID = Database.transactionGet(tx, "userID")
                    settings.userID = (userID === false ? 0 : parseInt(userID));
                    
                    var userToken = Database.transactionGet(tx, "userToken");
                    settings.userToken = (userToken === false ? "" : userToken);

                    var userName = Database.transactionGet(tx, "userName");
                    settings.userName = (userName === false ? "" : userName);

                    var userPassword = Database.transactionGet(tx, "userPassword");
                    settings.userPassword = (userPassword === false ? "" : userPassword);
                });
     
            // articles
            ArticlesDatabase.load();

            // Testing
            // Clipboard.text = "http://www.w3schools.com/jsref/met_document_queryselector.asp"
        }        
    }

    DownloadManager
    {
        id: downloadmanager
    }

    Component.onCompleted: {
        downloadmanager.itemParsed.connect(store);
        downloadmanager.notification.connect(pushNotification);
    }
  
    //////////////////////////////////////
    // Notifications
    ///////////////////
    function pushNotification(notificationType, notificationSummary, notificationBody) {
        var notificationCategory
        switch(notificationType) {
        case "OK":
            notificationCategory = "x-jolla.store.sideloading-success"
            break
        case "INFO":
            notificationCategory = "x-jolla.lipstick.credentials.needUpdate.notification"
            break
        case "WARNING":
            notificationCategory = "x-jolla.store.error"
            break
        case "ERROR":
            notificationCategory = "x-jolla.store.error"
            break
        }

        notification.category = notificationCategory
        notification.previewSummary = notificationSummary
        notification.previewBody = notificationBody
        notification.publish()
    }

    Notification {
        id: notification
        category: "x-nemo.email.error"
        itemCount: 1
    }

}


