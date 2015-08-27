import QtQuick 2.0
import QtWebKit 3.0
import Sailfish.Silica 1.0

Page {
    id: postarticlepage
    // property alias url: webview.url
    property string serverurl: ""
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

        experimental.certificateVerificationDialog: Item {
            Component.onCompleted: {
                model.accept();
            }
        }
        
        experimental.userScripts: [
            Qt.resolvedUrl("../js/Console.js"),
        ]

        experimental.onMessageReceived: {
            // for console.log output
            listener.execute(message)
        }

        Component.onCompleted: {
            // console.log("USERNAME: " + postarticlepage.username + "::" + postarticlepage.password)
            // console.log("URL: " + postarticlepage.url)
            webview.url = serverurl + "/?action=add&url=" + Qt.btoa(Clipboard.text)
        }

        onLoadingChanged: {
            if(loadRequest.status === WebView.LoadSucceededStatus)
            {
                webview.experimental.evaluateJavaScript("document.querySelector('input[name=login]').setAttribute('value', '" + postarticlepage.username + "')");
                webview.experimental.evaluateJavaScript("document.querySelector('input[name=password]').setAttribute('value', '" + postarticlepage.password + "')");
                webview.experimental.evaluateJavaScript("document.getElementById('longlastingsession').checked = true");
            }
            else if(loadRequest.status === WebView.LoadFailedStatus){
                mainwindow.pushNotification("ERROR", qsTr("Failed to sign in"), qsTr("Server error, check settings."))
                pageStack.completeAnimation()
                pageStack.pop()
            }
        }
        
    } // WebView
} // Page