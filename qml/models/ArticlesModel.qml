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

ListModel
{
    id: articlesmodel

    function populate(sqlrows)
    {
        articlesmodel.clear();
        appendRows(sqlrows)
    }

    function appendRows(sqlrows)
    {
        for(var i = 0; i < sqlrows.length; i++)
        {
            var row = sqlrows[i]

            articlesmodel.append({"url": row.url, "id": row.id, "title": row.title, "content": row.content, "pubDate": row.pubDate, "favorite": row.favoriteFlag, "archive": row.archiveFlag, "syncAction": row.syncAction})
        }
    }
}
