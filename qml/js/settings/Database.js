.pragma library

.import QtQuick.LocalStorage 2.0 as Storage

function instance()
{
    return openDatabase("1.0");
}

// function checkDBUpgrade()
// {
//     var db = openDatabase("");

//     if(db.version === "1.0")
//     {
//         /* Drop Old "Preview" Database */
//         db.changeVersion("1.0", "1.1",
//                          function(tx) {
//                              tx.executeSql("DROP TABLE IF EXISTS BrowserSettings");
//                              tx.executeSql("DROP TABLE IF EXISTS Favorites");
//                              tx.executeSql("DROP TABLE IF EXISTS SearchEngines");
//                          });

//         checkDBUpgrade();
//         return;
//     }

//     if((db.version === "") || (db.version === "1.1"))
//     {
//         db.changeVersion(db.version, "1.2",
//                          function(tx) {
//                              tx.executeSql("DROP TABLE IF EXISTS UserAgents");
//                          });

//         checkDBUpgrade();
//         return;
//     }
// }

function openDatabase(version)
{
    return Storage.LocalStorage.openDatabaseSync("SailabagDB", version, "Sailabag Database for settings", 5000000);  /* DB Size: 5MB */
}

function set(setting, value)
{
    var db = instance();

    db.transaction(function(tx) {
        transactionSet(tx, setting, value);
    });
}

function get(setting)
{
    var db = instance();
    var res = false;

    db.readTransaction(function(tx) {
        res = transactionGet(tx, setting);
    });

    return res;
}

function transactionSet(tx, setting, value)
{
    tx.executeSql("INSERT OR REPLACE INTO Settings (name, value) VALUES (?, ?);", [setting, value]);
}

function transactionGet(tx, setting)
{
    var r = tx.executeSql("SELECT value FROM Settings WHERE name = ?;", [setting]);

    if(r.rows.length > 0)
        return r.rows.item(0).value;

    return false;
}

function load()
{
    // checkDBUpgrade();
    var db = instance();

    db.transaction(function(tx) {
        tx.executeSql("CREATE TABLE IF NOT EXISTS Settings(name TEXT PRIMARY KEY, value TEXT)");
    });
}

function transaction(txfunc)
{
    instance().transaction(txfunc);
}
