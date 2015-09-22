.pragma library

.import QtQuick.LocalStorage 2.0 as Storage

function sanitizeString(s)
{
    // Trim whitespace at the beginning / end
    s = s.replace(/(^\s+|\s+$)/g,'')

    // Replace multiple whitespaces with one whitespace
    s = s.replace(/\s+/g, ' ')

    return s
}

function instance()
{
    return Storage.LocalStorage.openDatabaseSync("SailabagDB", "1.0", "Articles", 5000000);  /* DB Size: 5MB */
}

function load()
{
    var db = instance();

    db.transaction(function(tx) {
        tx.executeSql("CREATE TABLE IF NOT EXISTS Articles (url TEXT PRIMARY KEY" +
		      ", id INTEGER" +
		      ", title TEXT" +
		      ", content TEXT" +
		      ", pubDate DATETIME" +
		      ", favoriteFlag INTEGER" +
		      ", archiveFlag INTEGER" +
		      ", deletionFlag INTEGER" +
		      ", syncState INTEGER" +
		      ", UNIQUE (url, id))");
    });
}

function clear()
{
    instance().transaction(function(tx) {
        tx.executeSql("DROP TABLE IF EXISTS Articles");
    });

    load();
}

function invalidateEntries()
{
    instance().transaction(function(tx) {
        var res = tx.executeSql("SELECT * FROM Articles")

	for(var i = 0; i < res.rows.length; i++){
	    tx.executeSql("UPDATE Articles SET syncState=-1 WHERE url='" + res.rows[i].url + "'")
	}
    });
}

function removeInvalidEntries()
{
    instance().transaction(function(tx) {
        var res = tx.executeSql("SELECT * FROM Articles WHERE syncState=-1")

	for(var i = 0; i < res.rows.length; i++){
	    tx.executeSql("DELETE FROM Articles WHERE url=?", [res.rows[i].url]);
	}
    });
}

function removeID(delID)
{    
    instance().transaction(function(tx) {
	tx.executeSql("DELETE FROM Articles WHERE id=?", [delID]);
    });
}

function store(url, id, title, content, pubDate)
{
    instance().transaction(function(tx) {
        var res = tx.executeSql("SELECT * FROM Articles WHERE url='" + url + "'")

	if(res.rows.length) {
	    instance().transaction(function(tx) {
		tx.executeSql("UPDATE Articles SET syncState=0 WHERE url='" + url + "'")
	    })
	}
	else{
	    var title_san = sanitizeString(title)
	    instance().transaction(function(tx) {
		tx.executeSql("INSERT OR IGNORE INTO Articles (url, id, title, content, pubDate, favoriteFlag, archiveFlag, deletionFlag, syncState) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)", [url, id, title_san, content, pubDate, 0, 0, 0, 0]);
	    });
	}
    });
}

function queryUnreadArticles(model)
{  
    model.clear();
    
    instance().transaction(function(tx) {
        var res = tx.executeSql("SELECT * FROM Articles WHERE deletionFlag=0 AND archiveFlag=0 ORDER BY id DESC")

        if(res.rows.length)
            model.populate(res.rows);
        else
            model.clear();
    });
}

function queryStagedArticles(model)
{
    model.clear();

    instance().transaction(function(tx) {
        var dels = tx.executeSql("SELECT * FROM Articles WHERE deletionFlag=1")
        var archs = tx.executeSql("SELECT * FROM Articles WHERE archiveFlag=1")

        if(dels.rows.length)
            model.appendRows(dels.rows);
	if(archs.rows.length)
            model.appendRows(archs.rows);
    });
}

function markAsRead(model, readUrl)
{
    instance().transaction(function(tx) {
        tx.executeSql("UPDATE Articles SET archiveFlag=1 WHERE url='" + readUrl + "'")
    });
}

function stageForDeletion(model, delUrl)
{
    instance().transaction(function(tx) {
        tx.executeSql("UPDATE Articles SET deletionFlag=1 WHERE url='" + delUrl + "'")
    });
}

function markAsUnread(id)
{
    instance().transaction(function(tx) {
        tx.executeSql("UPDATE Articles SET deletionFlag=0 WHERE id=?", [id])
        tx.executeSql("UPDATE Articles SET archiveFlag=0 WHERE id=?", [id] )
    });
}
