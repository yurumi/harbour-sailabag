import QtQuick 2.1

ListModel
{
    id: articlesmodel

    function populate(sqlrows)
    {
        articlesmodel.clear();

        for(var i = 0; i < sqlrows.length; i++)
        {
            var row = sqlrows[i]

            articlesmodel.append({"url": row.url, "id": row.id, "title": row.title, "content": row.content, "pubDate": row.pubDate})
        }
    }
}
