import QtQuick 2.1
import Sailfish.Silica 1.0

import "../models"
import "../js/articles/ArticlesDatabase.js" as ArticlesDatabase

Page {
    id: articleoverview

    property ArticlesModel articlesModel: ArticlesModel { }

    property int signInState: -1

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

    function signIn()
    {
        console.log("Signing in...")
        mainwindow.downloadmanager.updateSignInState(mainwindow.settings.serverURL)
        // pageStack.push(Qt.resolvedUrl("SignInPage.qml"), {"url": mainwindow.settings.serverURL,
        //                                                   "username": mainwindow.settings.userName,
        //                                                   "password": mainwindow.settings.userPassword}
        // )
    }

    function storeSignInState(signedIn)
    {
        console.log("SIGNINSTATE: " + signedIn)
    }
    
    Component.onCompleted: {
        mainwindow.downloadmanager.syncFinished.connect(updateModel);
        mainwindow.downloadmanager.downloadError.connect(downloadError);
        mainwindow.downloadmanager.signInStateUpdate.connect(storeSignInState);
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
                text: qsTr("Send clipboard to server")
                onClicked: {
                    if (Clipboard.hasText) {
                        var serverurl = mainwindow.settings.serverURL
                        var username = mainwindow.settings.userName
                        var password = mainwindow.settings.userPassword

                        if ( (serverurl === "") || (username === "") || (password === "") ){
                            mainwindow.pushNotification("INFO", qsTr("Login information incomplete"), qsTr("Check settings page."))    
                        }else{
                            // articleoverview.signIn()
                            console.log("POST: " + username + "::" + password)
                            pageStack.push(Qt.resolvedUrl("PostArticlePage.qml"), {"serverurl": serverurl,
                                                                                   "username": username,
                                                                                   "password": password})
                        }
                    }else{
                        mainwindow.pushNotification("INFO", qsTr("Clipboard is empty"), qsTr("Mark URL to copy to the clipboard."))
                    }           

                    // mainwindow.sendClipboard()
                }
            }
        }

        // PushUpMenu {
        //     MenuItem {
        //         text: qsTr("Scroll to top")
        //         onClicked: { articleListView.scrollToTop() }
        //     }
        // }

        header: PageHeader {
            title: qsTr("Article Overview")
        }

        delegate: Item {
            id: articleDelegate
            width: ListView.view.width
            height: menuOpen ? contextMenu.height + contentItem.height : contentItem.height

            property Item contextMenu
            property bool menuOpen: contextMenu != null && contextMenu.parent === articleDelegate

            function remove() {
                articleDeleteRemorse.execute(articleDelegate, qsTr("Deleting"), function() {
                    ArticlesDatabase.markForDeletion(articlesModel, url)
                }, 2000)
            }

            RemorseItem {
                id: articleDeleteRemorse
            }
            
            BackgroundItem {
                id: contentItem
                height: delegateColumn.height
                width: parent.width

                Column
                {
                    id: delegateColumn
                    width: parent.width
                    spacing: 5

                    Label {
                        id: titleLBL
                        text: title
                        color: articleDelegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                        wrapMode: Text.Wrap
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: Theme.paddingLarge
                        }
                    }
                    Label {
                        id: urlLBL
                        text: url
                        color: articleDelegate.highlighted ? Theme.highlightColor : Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        truncationMode: TruncationMode.Fade
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: Theme.paddingLarge
                        }
                    }
                    // Label {
                        //     id: pubdateLBL
                        //     text: pubDate
                        //     color: articleDelegate.highlighted ? Theme.highlightColor : Theme.secondaryColor
                        //     font.pixelSize: Theme.fontSizeExtraSmall
                        //     truncationMode: TruncationMode.Fade
                        //     anchors {   left: parent.left
                        //                 right: parent.right
                        //                 margins: Theme.paddingLarge
                        //             }
                        // }
                    // Label {
                    //     id: idLBL
                    //     text: id
                    //     color: articleDelegate.highlighted ? Theme.highlightColor : Theme.secondaryColor
                    //     font.pixelSize: Theme.fontSizeExtraSmall
                    //     truncationMode: TruncationMode.Fade
                    //     anchors {
                    //         left: parent.left
                    //         right: parent.right
                    //         margins: Theme.paddingLarge
                    //     }
                    // }
                    Separator {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        color: Theme.primaryColor
                    }
                }

                onPressAndHold: {
                    if (!contextMenu) {
                        contextMenu = contextMenuComponent.createObject(articleListView)
                    }
                    contextMenu.show(articleDelegate)
                }
                
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ArticleViewPage.qml"), {"articleUrl": url, "articleTitle": title, "articleContent": content, "articlePubDate": pubDate})
                }
            } // BackgroundItem
            
            Component {
                id: contextMenuComponent
                
                ContextMenu {
                    MenuItem {
                        text: qsTr("Mark as read")
                        onClicked: console.log("Clicked Option 1")
                    }
                    MenuItem {
                        text: qsTr("Mark for deletion")
                        onClicked: {
                            contextMenu.hide()

                            remove()
                            // ArticlesDatabase.markForDeletion(articlesModel, url)
                        }
                    }
                    MenuItem {
                        text: qsTr("Delete")
                        onClicked: {
                            contextMenu.hide()

                            var serverurl = mainwindow.settings.serverURL
                            var username = mainwindow.settings.userName
                            var password = mainwindow.settings.userPassword

                            if ( (serverurl === "") || (username === "") || (password === "") ){
                                mainwindow.pushNotification("INFO", qsTr("Login information incomplete"), qsTr("Check settings page."))    
                            }else{
                                pageStack.push(Qt.resolvedUrl("DeleteArticlePage.qml"), {"serverurl": serverurl,
                                                                                         "username": username,
                                                                                         "password": password,
                                                                                         "delID": id})
                            }
                        }
                    }
                    
                }
            } // ContextMenu

        } // delegate

        VerticalScrollDecorator {}

    } // ListView

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: false
    }
}
