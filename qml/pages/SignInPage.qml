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
        //     // console.log("Message nötig" + message)
        // }
        
        // function check(){
        //     console.log("Hier check")
        //     experimental.postMessage("set_username");
        // }
                
        Component.onCompleted: {
            // console.log("USERNAME: " + signinpage.username + "::" + signinpage.password)
            // console.log("URL: " + signinpage.url)
            
            // var data = new Object;
            // data.type = "console_log";
            // data.log = "Bitte bitte bitte bitte";

            // console.log("Vorher")
            // experimental.postMessage(JSON.stringify(data));
            // experimental.postMessage("set_username");
            // check();
            // experimental.postMessage("set_userpassword");
            // experimental.postMessage("OMGWTF");
            // console.log("Nachher")
        }

        onLoadingChanged: {
            console.log("LoadingChanged: " + loadRequest.status)
            if(loadRequest.status === WebView.LoadSucceededStatus)
            {
                console.log("Loading SUCCEEDED")             
                webview.experimental.evaluateJavaScript("document.querySelector('input[name=login]').setAttribute('value', '" + signinpage.username + "')");
                webview.experimental.evaluateJavaScript("document.querySelector('input[name=password]').setAttribute('value', '" + signinpage.password + "')");
                //webview.experimental.evaluateJavaScript("document.getElementById('longlastingsession').checked = true");
                // webview.experimental.evaluateJavaScript("document.querySelector('button[type=submit]').click()");
            }
            else if(loadRequest.status === WebView.LoadFailedStatus){
                console.log("Loading FAILED")
                mainwindow.pushNotification("ERROR", qsTr("Failed to sign in"), qsTr("Server error, check settings."))
                pageStack.pop()
            }
        }
        
    }
}