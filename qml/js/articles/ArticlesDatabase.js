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
    return Storage.LocalStorage.openDatabaseSync("SailorbagDB", "1.0", "Articles", 5000000);  /* DB Size: 5MB */
}

function load()
{
    var db = instance();

    db.transaction(function(tx) {
        tx.executeSql("CREATE TABLE IF NOT EXISTS Articles (url TEXT PRIMARY KEY, 
                                                            id INTEGER, 
                                                            title TEXT, 
                                                            content TEXT, 
                                                            pubDate DATETIME, 
                                                            favoriteFlag INTEGER, 
                                                            archiveFlag INTEGER, 
                                                            deletionFlag INTEGER, 
                                                            syncState INTEGER, 
                                                            UNIQUE (url, id))");
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
	    console.log("Invalidate article " + res.rows[i].id)
	    tx.executeSql("UPDATE Articles SET syncState=-1 WHERE url='" + res.rows[i].url + "'")
	}
    });
}

function removeInvalidEntries()
{
    instance().transaction(function(tx) {
        var res = tx.executeSql("SELECT * FROM Articles WHERE syncState=-1")

	for(var i = 0; i < res.rows.length; i++){
	    console.log("Remove invalid article " + res.rows[i].id)
	    tx.executeSql("DELETE FROM Articles WHERE url=?", [res.rows[i].url]);
	}
    });
}

function store(url, id, title, content, pubDate)
{
    instance().transaction(function(tx) {
        var res = tx.executeSql("SELECT * FROM Articles WHERE url='" + url + "'")

	if(res.rows.length) {
	    instance().transaction(function(tx) {
		console.log("Article exists, setting syncState (" + res.rows[0].id + ")")
		tx.executeSql("UPDATE Articles SET syncState=0 WHERE url='" + url + "'")
	    })
	}
	else{
	    console.log("New article (" + id + ")")
	    var title_san = sanitizeString(title)
	    instance().transaction(function(tx) {
		// tx.executeSql("INSERT OR REPLACE INTO Articles (url, id, title, content, pubDate, favoriteFlag, archiveFlag, deletionFlag) VALUES(?, ?, ?, ?, ?, ?, ?, ?)", [url, id, title_san, content, pubDate, 0, 0, 0]);
		tx.executeSql("INSERT OR IGNORE INTO Articles (url, id, title, content, pubDate, favoriteFlag, archiveFlag, deletionFlag, syncState) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)", [url, id, title_san, content, pubDate, 0, 0, 0, 0]);
	    });
	}
    });
}

// function remove(url)
// {
//     instance().transaction(function(tx) {
//         tx.executeSql("DELETE FROM History WHERE url=?", [url]);
//     });
// }

function queryUnreadArticles(model)
{  
    model.clear();
    
    instance().transaction(function(tx) {
        var res = tx.executeSql("SELECT * FROM Articles WHERE deletionFlag=0 ORDER BY id DESC")

        if(res.rows.length)
            model.populate(res.rows);
        else
            model.clear();
    });
}

function queryArticlesToDelete(model)
{  
    model.clear();
    
    instance().transaction(function(tx) {
        var res = tx.executeSql("SELECT * FROM Articles WHERE deletionFlag=1")

        if(res.rows.length)
            model.populate(res.rows);
        else
            model.clear();
    });
}

function markForDeletion(model, delUrl)
{
    instance().transaction(function(tx) {
        // var res = tx.executeSql("DELETE FROM Articles WHERE url='" + delUrl + "'")
        tx.executeSql("UPDATE Articles SET deletionFlag=1 WHERE url='" + delUrl + "'")
    });

    queryUnreadArticles(model)
}

function markAsUnread(model, delUrl)
{
    instance().transaction(function(tx) {
        // var res = tx.executeSql("DELETE FROM Articles WHERE url='" + delUrl + "'")
        tx.executeSql("UPDATE Articles SET deletionFlag=0 WHERE url='" + delUrl + "'")
        tx.executeSql("UPDATE Articles SET archiveFlag=0 WHERE url='" + delUrl + "'")
    });

    queryArticlesToDelete(model)
}
