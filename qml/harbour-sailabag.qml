/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import harbour.tasklist.notifications 1.0
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


