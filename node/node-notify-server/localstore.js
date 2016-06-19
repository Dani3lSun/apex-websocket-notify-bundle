//
// LocalStorage (in Memory with alasql DB)
//
var prefs = require("./prefs");
var alasql = require('alasql');
// create user table with indexes
// TABLE users
alasql.promise("CREATE TABLE users (userid string, room string, session string, created DATE)")
    .then(function(res) {
        // logging
        prefs.doLog('alasql - Create table users DONE');
    }).catch(function(err) {
        // logging
        prefs.doLog('alasql - Create table users ERROR', err);
    });
// INDEX i_users_userid
alasql.promise("CREATE INDEX i_users_userid ON users(userid)")
    .then(function(res) {
        // logging
        prefs.doLog('alasql - Create index i_users_userid DONE');
    }).catch(function(err) {
        // logging
        prefs.doLog('alasql - Create index i_users_userid ERROR', err);
    });
// INDEX i_users_room
alasql.promise("CREATE INDEX i_users_room ON users(room)")
    .then(function(res) {
        // logging
        prefs.doLog('alasql - Create index i_users_room DONE');
    }).catch(function(err) {
        // logging
        prefs.doLog('alasql - Create index i_users_room ERROR', err);
    });
// INDEX i_users_created
alasql.promise("CREATE INDEX i_users_created ON users(created)")
    .then(function(res) {
        // logging
        prefs.doLog('alasql - Create index i_users_created DONE');
    }).catch(function(err) {
        // logging
        prefs.doLog('alasql - Create index i_users_created ERROR', err);
    });
//
// Name space
//
module.exports = {
    // format date to YYYYMMDDmmss
    dateFormat: function(pDate) {
        function pad2(number) {
            return (number < 10 ? '0' : '') + number;
        }
        pDate = new Date();
        var yyyy = pDate.getFullYear().toString();
        var MM = pad2(pDate.getMonth() + 1);
        var dd = pad2(pDate.getDate());
        var hh = pad2(pDate.getHours());
        var mm = pad2(pDate.getMinutes());
        var ss = pad2(pDate.getSeconds());

        return yyyy + MM + dd + hh + mm + ss;
    },
    // format date to DD.MM.YYYY HH24:MI
    dateTimeFormat: function(pDate) {
        function pad2(number) {
            return (number < 10 ? '0' : '') + number;
        }
        pDate = new Date();
        var yyyy = pDate.getFullYear().toString();
        var MM = pad2(pDate.getMonth() + 1);
        var dd = pad2(pDate.getDate());
        var hh = pad2(pDate.getHours());
        var mm = pad2(pDate.getMinutes());

        return dd + '.' + MM + '.' + yyyy + ' ' + hh + ':' + mm;
    },
    // Save Client Session in user DB
    saveUserSession: function(pUserId, pSocketRoom, pSocketSessionid, callback) {
        var lDate = new Date();
        var lDateFormat = module.exports.dateFormat(lDate);
        alasql.promise("INSERT INTO users VALUES (UPPER('" + pUserId + "'),UPPER('" + pSocketRoom + "'),'" + pSocketSessionid + "','" + lDateFormat + "')")
            .then(function(res) {
                // reindex users table indexes
                alasql("REINDEX i_users_userid");
                alasql("REINDEX i_users_room");
                alasql("REINDEX i_users_created");
                // logging
                prefs.doLog('alasql - Insert users DONE');
                // callback
                callback(res);
            }).catch(function(err) {
                // logging
                prefs.doLog('alasql - Insert users ERROR', err);
                // callback
                callback(err);
            });
    },
    // Get all User Sessions from user DB
    getUserSession: function(pUserid, pSocketRoom, callback) {
        var sqlString = "";
        // all users public
        if (pUserid.toUpperCase() === 'ALL' && pSocketRoom.toUpperCase() === 'PUBLIC') {
            sqlString = "SELECT session FROM users WHERE room = UPPER('" + pSocketRoom + "')";
            // specific user and room
        } else {
            sqlString = "SELECT session FROM users WHERE userid = UPPER('" + pUserid + "') AND room = UPPER('" + pSocketRoom + "')";
        }
        alasql.promise(sqlString)
            .then(function(res) {
                // logging
                prefs.doLog('alasql - Select user session DONE');
                // callback
                callback(res);
            }).catch(function(err) {
                // logging
                prefs.doLog('alasql - Select user session ERROR', err);
                // callback
                callback(err);
            });
    },
    // Delete Sessions older than 2 hours
    deleteOldSessions: function(callback) {
        var lDate = new Date();
        lDate = lDate.setHours(lDate.getHours() - 2);
        var lDateFormat = module.exports.dateFormat(lDate);
        alasql.promise("DELETE FROM users WHERE created < '" + lDateFormat + "'")
            .then(function(res) {
                // reindex users table
                alasql("REINDEX i_users_userid");
                alasql("REINDEX i_users_room");
                alasql("REINDEX i_users_created");
                // logging
                prefs.doLog('alasql - Delete users DONE');
                // callback
                callback(res);
            }).catch(function(err) {
                // logging
                prefs.doLog('alasql - Delete ERROR', err);
                callback(err);
            });
    },
    // Get DB stats
    getDbStats: function(callback) {
        alasql.promise("SELECT COUNT(*) AS counter, room FROM users GROUP BY room")
            .then(function(res) {
                // logging
                prefs.doLog('alasql - Select DB stats DONE');
                // callback
                callback(res);
            }).catch(function(err) {
                // logging
                prefs.doLog('alasql - Select DB stats ERROR', err);
                // callback
                callback(err);
            });
    }
};
