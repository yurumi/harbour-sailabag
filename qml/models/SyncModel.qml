import QtQuick 2.1

ListModel
{
    id: syncmodel

    function populate(sqlrows)
    {
        syncmodel.clear();
        appendRows(sqlrows)
    }

    function appendRows(sqlrows)
    {
        for(var i = 0; i < sqlrows.length; i++){
            var row = sqlrows[i]
            var sectionString = row.deletionFlag ? "delete" : "archive"
           
            syncmodel.append({"url": row.url, "title": row.title, "id": row.id, "content": row.content, "archiveFlag": row.archiveFlag, "deletionFlag": row.deletionFlag, "sectionString": sectionString})
        }
    }

}
