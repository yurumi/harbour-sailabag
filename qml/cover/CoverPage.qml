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

CoverBackground {

    property int numUnreadArticles: 0

    CoverPlaceholder {
        text: "Sailabag"
        icon.source: "qrc:/qml/img/coverbackground.png"
    }
    
    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                mainwindow.downloadUnreadArticles()
                // mainwindow.activate()
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                mainwindow.activate() 
                mainwindow.remorseSendClipboard()
            }
        }
    }
}


