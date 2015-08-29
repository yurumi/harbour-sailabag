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
import QtWebKit 3.0
import Sailfish.Silica 1.0

Page {
    id: signinpage
    property alias url: webview.url
    property string username: ""
    property string password: ""

    SilicaWebView {
        id: webview
        anchors.fill: parent

        WebViewListener { id: listener }

        experimental.preferences.pluginsEnabled: true
        experimental.preferences.javascriptEnabled: true
        experimental.preferences.localStorageEnabled: true
        experimental.preferences.navigatorQtObjectEnabled: true
        experimental.preferences.developerExtrasEnabled: true

        // experimental.userScripts: [
        //     Qt.resolvedUrl("../js/Console.js"),
        //     Qt.resolvedUrl("../js/credentialsAutoFill.js"),
        //     Qt.resolvedUrl("../js/MessageListener.js")
        // ]

        // experimental.onMessageReceived: {
        //     // for console.log output
        //     listener.execute(message)
        // }
                
        Component.onCompleted: {
        }

        onLoadingChanged: {
            if(loadRequest.status === WebView.LoadSucceededStatus)
            {
                webview.experimental.evaluateJavaScript("document.querySelector('input[name=login]').setAttribute('value', '" + signinpage.username + "')");
                webview.experimental.evaluateJavaScript("document.querySelector('input[name=password]').setAttribute('value', '" + signinpage.password + "')");
                //webview.experimental.evaluateJavaScript("document.getElementById('longlastingsession').checked = true");
                // webview.experimental.evaluateJavaScript("document.querySelector('button[type=submit]').click()");
            }
            else if(loadRequest.status === WebView.LoadFailedStatus){
                mainwindow.pushNotification("ERROR", qsTr("Failed to sign in"), qsTr("Server error, check settings."))
                pageStack.pop()
            }
        }
        
    }
}