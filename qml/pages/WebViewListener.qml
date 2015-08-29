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

Item
{
    id: listener

    QtObject
    {
        readonly property var dispatcher: { "console_log": onConsoleLog,
                                            "submit": onFormSubmit }

        id: listenerprivate

        function onConsoleLog(data) {
            console.log(data.log);
        }

        function onFormSubmit(data) {
            // linkmenu.hide();

            // if((mainwindow.settings.clearonexit === false) && Credentials.needsDialog(Database.instance(), url.toString(), data)) {
            //     credentialdialog.url = url.toString();
            //     credentialdialog.logindata = data;
            //     credentialdialog.show();
            // }
        }
    }

    function execute(message)
    {
        var data = JSON.parse(message.data);
        var eventfn = listenerprivate.dispatcher[data.type];

        if(eventfn)
            eventfn(data);
    }
}
