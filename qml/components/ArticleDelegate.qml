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
