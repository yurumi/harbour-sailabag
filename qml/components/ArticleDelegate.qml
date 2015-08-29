import QtQuick 2.1
import Sailfish.Silica 1.0

import "../models"
import "../js/articles/ArticlesDatabase.js" as ArticlesDatabase

ListItem {
    id: articleDelegate
    menu: contextMenu
    contentHeight: delegateColumn.height

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

} // delegate
