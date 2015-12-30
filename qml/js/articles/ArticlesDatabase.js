.pragma library

.import QtQuick.LocalStorage 2.0 as Storage

var DB_VERSION = "1.5";

function sanitizeString(s)
{
    // Trim whitespace at the beginning / end
    s = s.replace(/(^\s+|\s+$)/g,'')

    // Replace multiple whitespaces with one whitespace
    s = s.replace(/\s+/g, ' ')

    return s
}

function checkArticlesDbVersion()
{
    // try{
    var db = Storage.LocalStorage.openDatabaseSync("SailabagDB", "", "Articles", 5000000);  /* DB Size: 5MB */
    console.log("CHECK DB VERSION: ", db.version)
    if (db.version === "") {
        db.changeVersion("", DB_VERSION, initDb);
	return true;
    }

    return db.version === DB_VERSION;
    // } catch (sqlErr) {
    //     console.log("SQL Error: ", sqlErr);
    // }
}

function updateDbSchema()
{
    try{
    	var db = Storage.LocalStorage.openDatabaseSync("SailabagDB", DB_VERSION, "Articles", 5000000);  /* DB Size: 5MB */
    } catch (sqlErr) {
        console.log("(UpdateSchema) SQL Error: ", sqlErr);
	
    	if(sqlErr.code === SQLException.VERSION_ERR){
    	    var db = Storage.LocalStorage.openDatabaseSync("SailabagDB", "", "Articles", 5000000);  /* DB Size: 5MB */
    	    var currentVersion = db.version;
    	    var nextVersion = currentVersion

    	    // Update V1.0 --> V1.5
    	    if(currentVersion === "1.0"){
    		nextVersion = "1.5"
    		console.log("Update article DB schema from version", currentVersion, "to version", nextVersion);
    		db.changeVersion(currentVersion, nextVersion, function(tx){
    		    tx.executeSql("ALTER TABLE Articles ADD COLUMN syncAction TEXT");

    		    var res = tx.executeSql("SELECT * FROM Articles WHERE archiveFlag=1")
    		    for(var i=0; i < res.rows.length; i++){
    			tx.executeSql("UPDATE Articles SET archiveFlag=0, syncState=2, syncAction='archive' WHERE id=?", res.rows[i].id);
    		    }

    		    res = tx.executeSql("SELECT * FROM Articles WHERE deletionFlag=1")
    		    for(var i=0; i < res.rows.length; i++){
    			tx.executeSql("UPDATE Articles SET deletionFlag=0, syncState=2, syncAction='delete' WHERE id=?", res.rows[i].id);
    		    }

    		    res = tx.executeSql("SELECT * FROM Articles WHERE syncState=0")
    		    for(var i=0; i < res.rows.length; i++){
    			tx.executeSql("UPDATE Articles SET syncState=1, syncAction='none' WHERE id=?", res.rows[i].id);
    		    }
    		})
    	    }// V1.0 --> V1.5

    	    // Next update try
    	    updateDbSchema();
	    
    	}// VERSION_ERR
    }// catch (sqlErr)
}

function instance()
{
    return Storage.LocalStorage.openDatabaseSync("SailabagDB", "", "Articles", 5000000);  /* DB Size: 5MB */
}

function initDb(tx)
{
    console.log("INIT DB, version:", DB_VERSION)

    tx.executeSql("CREATE TABLE IF NOT EXISTS Articles (\
url TEXT PRIMARY KEY, id INTEGER, title TEXT, content TEXT,\
 pubDate DATETIME, favoriteFlag INTEGER, archiveFlag INTEGER,\
deletionFlag INTEGER, syncState INTEGER, syncAction TEXT, UNIQUE (url, id))"
		 )
}

function clear()
{
    instance().transaction(function(tx) {
        tx.executeSql("DROP TABLE IF EXISTS Articles");
	initDb(tx)
    });
}

function invalidateEntries(articleCategory)
{
    instance().transaction(function(tx) {
	if(articleCategory === "unread"){
	    var res = tx.executeSql("SELECT * FROM Articles WHERE archiveFlag=0")
	    for(var i = 0; i < res.rows.length; i++){
		tx.executeSql("UPDATE Articles SET syncState=" + -res.rows[i].syncState + " WHERE id=" + res.rows[i].id)
	    }
	}
	else if(articleCategory === "favorite"){
	    var res = tx.executeSql("SELECT * FROM Articles WHERE favoriteFlag=1")
	    for(var i = 0; i < res.rows.length; i++){
		tx.executeSql("UPDATE Articles SET favoriteFlag=0 WHERE id=" + res.rows[i].id)
	    }    
	}
	else if(articleCategory === "archived"){
	    var res = tx.executeSql("SELECT * FROM Articles WHERE archiveFlag=1")
	    for(var i = 0; i < res.rows.length; i++){
		tx.executeSql("UPDATE Articles SET syncState=" + -res.rows[i].syncState + " WHERE id=" + res.rows[i].id)
	    }
	}
    });
}

function removeInvalidEntries()
{
    instance().transaction(function(tx) {
        var res = tx.executeSql("SELECT * FROM Articles WHERE syncState < 0")

	for(var i = 0; i < res.rows.length; i++){
	    tx.executeSql("DELETE FROM Articles WHERE id=?", [res.rows[i].id]);
	}
    });
}

function removeID(delID)
{    
    instance().transaction(function(tx) {
	tx.executeSql("DELETE FROM Articles WHERE id=?", [delID]);
    });
}

function store(url, id, title, content, pubDate, articleCategory)
{
    instance().transaction(function(tx) {
        var res = tx.executeSql("SELECT * FROM Articles WHERE url='" + url + "'")

	// article not in database --> store
	if(res.rows.length === 0) {
	    var favorite, archive	    
	    var title_san = sanitizeString(title)

	    switch(articleCategory){
	    case "home":
		favorite = 0
		archive = 0
		break
	    case "fav":
		favorite = 1
		archive = 0
		break
	    case "archive":
		favorite = 0
		archive = 1
		break
	    }
	    instance().transaction(function(tx) {
		tx.executeSql("INSERT OR IGNORE INTO Articles (url, id, title, content, pubDate, favoriteFlag, archiveFlag, deletionFlag, syncState, syncAction) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [url, id, title_san, content, pubDate, favorite, archive, 0, 1, "none"]);
	    });
	}
	// article already in database --> reset syncState, update unread/favorite/archive flags
	else{
	    instance().transaction(function(tx) {
		tx.executeSql("UPDATE Articles SET syncState=" + Math.abs(res.rows[0].syncState) + " WHERE url='" + url + "'")

		// no pending sync operation
		if(Math.abs(res.rows[0].syncState) === 1){
		    switch(articleCategory){
		    case "home":
			tx.executeSql("UPDATE Articles SET archiveFlag=0 WHERE url='" + url + "'")
			break
		    case "fav":
			tx.executeSql("UPDATE Articles SET favoriteFlag=1 WHERE url='" + url + "'")
			break
		    case "archive":
			tx.executeSql("UPDATE Articles SET archiveFlag=1 WHERE url='" + url + "'")
			break
		    }
		}else{
		    switch(articleCategory){
		    // case "home":
		    // 	tx.executeSql("UPDATE Articles SET archiveFlag=0 WHERE url='" + url + "'")
		    // 	break
		    case "fav":
			if(res.rows[0].syncAction !== "toggle_fav"){
			    tx.executeSql("UPDATE Articles SET favoriteFlag=1 WHERE url='" + url + "'")
			}else{
			    if(res.rows[0].favoriteFlag === 0){
				tx.executeSql("UPDATE Articles SET favoriteFlag=1, syncState=1, syncAction='none' WHERE url='" + url + "'")				
			    }
			}
			break
		    // case "archive":
		    // 	tx.executeSql("UPDATE Articles SET archiveFlag=1 WHERE url='" + url + "'")
		    // 	break
		    }
		}
	    })
	}
    });
}

function queryUnreadArticles(model)
{  
    model.clear();
    
    instance().transaction(function(tx) {
        var res = tx.executeSql("SELECT * FROM Articles WHERE archiveFlag=0 AND syncState=1 ORDER BY id DESC")

        if(res.rows.length)
            model.populate(res.rows);
        else
            model.clear();
    });
}

function queryFavoriteArticles(model)
{  
    model.clear();
    
    instance().transaction(function(tx) {
        var res = tx.executeSql("SELECT * FROM Articles WHERE favoriteFlag=1 AND syncAction!='toggle_fav' ORDER BY id DESC")

        if(res.rows.length)
            model.populate(res.rows);
        else
            model.clear();
    });
}

function queryArchivedArticles(model)
{  
    model.clear();
    
    instance().transaction(function(tx) {
        var res = tx.executeSql("SELECT * FROM Articles WHERE archiveFlag=1 AND syncState=1 ORDER BY id DESC")

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
        var dels = tx.executeSql("SELECT * FROM Articles WHERE syncState=2 AND syncAction='delete'")
        var archs = tx.executeSql("SELECT * FROM Articles WHERE syncState=2 AND syncAction='archive'")
        var unarchs = tx.executeSql("SELECT * FROM Articles WHERE syncState=2 AND syncAction='unarchive'")
        var favs = tx.executeSql("SELECT * FROM Articles WHERE syncState=2 AND syncAction='toggle_fav'")

        if(dels.rows.length)
            model.appendRows(dels.rows);
	if(archs.rows.length)
            model.appendRows(archs.rows);
	if(unarchs.rows.length)
            model.appendRows(unarchs.rows);
	if(favs.rows.length)
            model.appendRows(favs.rows);
    });
}

function markAsRead(model, readUrl)
{
    instance().transaction(function(tx) {
        tx.executeSql("UPDATE Articles SET syncState=2, syncAction='archive' WHERE url='" + readUrl + "'")
    });
}

function markAsUnread(model, readUrl)
{
    instance().transaction(function(tx) {
        tx.executeSql("UPDATE Articles SET syncState=2, syncAction='unarchive' WHERE url='" + readUrl + "'")
    });
}

function stageForToggleFavorite(model, readUrl)
{
    instance().transaction(function(tx) {
        tx.executeSql("UPDATE Articles SET syncState=2, syncAction='toggle_fav' WHERE url='" + readUrl + "'")
    });
}

function stageForDeletion(model, delUrl)
{
    instance().transaction(function(tx) {
        tx.executeSql("UPDATE Articles SET syncState=2, syncAction='delete' WHERE url='" + delUrl + "'")
    });
}

function undoSyncStage(id)
{
    instance().transaction(function(tx) {
        tx.executeSql("UPDATE Articles SET syncState=1, syncAction='none' WHERE id=?", [id] )
    });
}
