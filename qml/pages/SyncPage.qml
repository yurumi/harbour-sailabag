import QtQuick 2.1
import Sailfish.Silica 1.0

import "../models"
import "../js/articles/ArticlesDatabase.js" as ArticlesDatabase

Page {
    id: syncpage

    property SyncModel syncModel: SyncModel { }

    function updateModel()
    {
        ArticlesDatabase.queryArticlesToDelete(syncModel);
    //     busyIndicator.running = false
    //     busyIndicator.visible = false
    }
    
    // function downloadError()
    // {
    //     busyIndicator.running = false
    //     busyIndicator.visible = false
    // }

    
    Component.onCompleted: {
        // mainwindow.downloadmanager.syncFinished.connect(updateModel);
        // mainwindow.downloadmanager.downloadError.connect(downloadError);
        updateModel();
    }

    SilicaListView {
        id: syncListView
        anchors.fill: parent
        model: syncModel
        spacing: 10
        // opacity: busyIndicator.running ? 0.5 : 1.0
        
        // Behavior on opacity {
        //         NumberAnimation { duration: 300 }
        // }

        ViewPlaceholder {
            enabled: (syncListView.count === 0) //&& (busyIndicator.running === false)
            text: qsTr("No articles marked for deletion or marked as read.")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Synchronize")
                onClicked: pageStack.push(Qt.resolvedUrl("SyncPage.qml"))
            }
        }

        header: PageHeader {
            title: qsTr("Sync Overview")
        }

        delegate: Item {
            id: syncArticleDelegate
            width: ListView.view.width
            height: menuOpen ? contextMenu.height + contentItem.height : contentItem.height

            property Item contextMenu
            property bool menuOpen: contextMenu != null && contextMenu.parent === syncArticleDelegate

            // function remove() {
            //     articleDeleteRemorse.execute(articleDelegate, qsTr("Deleting"), function() {
            //         ArticlesDatabase.markForDeletion(articlesModel, url)
            //         // DB.removeTask(taskListModel.get(index).taskid)
            //         // taskListModel.remove(index)
            //     }, 2000)
            // }

            // RemorseItem {
            //     id: articleDeleteRemorse
            // }
            
            BackgroundItem {
                id: contentItem
                height: delegateColumn.height
                width: parent.width

                Row
                {
                    height: contentItem.height

                    IconButton {
                        id: syncButton
                        icon.source: "qrc:/qml/img/delete.png"
                        onClicked: console.log("clicked!")
                    }
                    
                    Column
                    {
                        id: delegateColumn
                        width: contentItem.width - syncButton.width
                        spacing: 5

                        Label {
                            id: titleLBL
                            text: title
                            color: syncArticleDelegate.highlighted ? Theme.highlightColor : Theme.primaryColor
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
                            color: syncArticleDelegate.highlighted ? Theme.highlightColor : Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                            truncationMode: TruncationMode.Fade
                            anchors {
                                left: parent.left
                                right: parent.right
                                margins: Theme.paddingLarge
                            }
                        }

                        Separator {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            color: Theme.primaryColor
                        }
                    } // Column
                } // Row

                onPressAndHold: {
                    if (!contextMenu) {
                        contextMenu = contextMenuComponent.createObject(syncListView)
                    }
                    contextMenu.show(syncArticleDelegate)
                }
                
            //     onClicked: {
            //         pageStack.push(Qt.resolvedUrl("ArticleViewPage.qml"), {"articleUrl": url, "articleTitle": title, "articleContent": content, "articlePubDate": pubDate})
            //     }
            } // BackgroundItem
            
            Component {
                id: contextMenuComponent
                
                ContextMenu {
                    MenuItem {
                        text: qsTr("Mark as unread")
                        onClicked: {
                            contextMenu.hide()
                            ArticlesDatabase.markAsUnread(syncModel, url)
                        }
                    }
                    // MenuItem {
                    //     text: qsTr("Mark for deletion")
                    //     onClicked: {
                    //         contextMenu.hide()
                    //         remove()
                    //         // ArticlesDatabase.markForDeletion(articlesModel, url)
                    //     }
                    // }
                }
            } // ContextMenu

        } // delegate

        VerticalScrollDecorator {}

    } // ListView

    // BusyIndicator {
    //     id: busyIndicator
    //     anchors.centerIn: parent
    //     //anchors.horizontalCenter: parent.horizontalCenter
    //     //anchors.bottom: parent.bottom
    //     //anchors.margins: Theme.paddingLarge
    //     running: false
    // }
}
