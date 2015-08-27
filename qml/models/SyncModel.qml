import QtQuick 2.1

ListModel
{
    id: syncmodel

    function populate(sqlrows)
    {
        syncmodel.clear();

        for(var i = 0; i < sqlrows.length; i++)
        {
            var row = sqlrows[i]

            syncmodel.append({"url": row.url, "title": row.title, "id": row.id, "content": row.content, "archiveFlag": row.archiveFlag, "deletionFlag": row.deletionFlag})
        }
    }
}
