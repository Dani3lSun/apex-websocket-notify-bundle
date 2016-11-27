//
// Helper functions for server
//
var fs = require('fs');
var url = require("url");
var encoding = require("encoding");
var localstore = require("./localstore");
var prefs = require("./prefs");
var serverPrefs = prefs.readPrefs('server');
var socketPrefs = prefs.readPrefs('socket');
var isPrivate = socketPrefs.private;
var isPublic = socketPrefs.public;
//
module.exports = {
    //
    // HTTP Error function
    //
    throwHttpError: function(errID, errMsg, res) {
        res.writeHead(errID, {
            "Content-Type": "text/plain"
        });
        res.write(errID + " " + errMsg + "\n");
        res.end();
    },
    //
    // HTTP Basic Auth
    //
    doBasicAuth: function(req, res) {
        var authUser = serverPrefs.authUser;
        var authPwd = serverPrefs.authPwd;
        // check if enabled in prefs
        if ((authUser) && (authPwd)) {
            var auth = req.headers['authorization'];
            // logging
            prefs.doLog("Authorization Header is: ", auth);
            // No Authorization header was passed in so it's the first time the browser hit us
            if (!auth) {
                res.statusCode = 401;
                res.setHeader('WWW-Authenticate', 'Basic realm="Secure Area"');
                res.end();
            }
            // The Authorization was passed in so now we validate it
            else if (auth) {
                // split, original auth looks like  "Basic Y2hhcmxlczoxMjM0NQ=="
                var tmp = auth.split(' ');
                // create a buffer and tell it the data coming in is base64
                var buf = new Buffer(tmp[1], 'base64');
                var plain_auth = buf.toString();
                // logging
                prefs.doLog("Decoded Authorization ", plain_auth);
                // At this point plain_auth = "username:password"
                var creds = plain_auth.split(':');
                var username = creds[0];
                var password = creds[1];
                // Is the username/password correct?
                if ((username == authUser) && (password == authPwd)) {
                    res.statusCode = 200;
                    return true;
                } else {
                    module.exports.throwHttpError(403, 'Forbidden', res);
                    return false;
                }
                // not enabled
            }
        } else {
            return true;
        }
    },
    //
    // Get Notify User Info from GET call
    //
    getNotifyInfo: function(req, res) {
        // parse URL
        var parsedUrl = url.parse(req.url, true);
        // get JSON
        var queryAsObject = parsedUrl.query;
        var jsonObject = JSON.stringify(queryAsObject);
        // logging
        prefs.doLog('notifyuser JSON:', jsonObject);
        // parse JSON content to vars
        var jsonContent = JSON.parse(jsonObject);
        var lUserId = jsonContent.userid;
        var lRoom = jsonContent.room;
        var lType = jsonContent.type;
        var lOptParam = jsonContent.optparam;
        // Admin Header vars
        var lNotifyTitle = req.headers['notify-title'];
        var lNotifyMessage = req.headers['notify-message'];
        // date time
        var lDate = new Date();
        var lDateFormat = localstore.dateTimeFormat(lDate);
        // check enabled sockets
        if (lRoom === 'private') {
            if (!(isPrivate)) {
                module.exports.throwHttpError(404, 'Room private is not enabled', res);
            }
        } else if (lRoom === 'public') {
            if (!(isPublic)) {
                module.exports.throwHttpError(404, 'Room public is not enabled', res);
            }
        }
        // check parameter
        if (lUserId && lRoom && lType && lNotifyTitle && lNotifyMessage) {
            if (lRoom === 'private' || lRoom === 'public') {
                if (lType === 'info' || lType === 'success' || lType === 'warn' || lType === 'error') {
                    lNotifyTitle = encoding.convert(lNotifyTitle, "Latin_1").toString();
                    lNotifyMessage = encoding.convert(lNotifyMessage, "Latin_1").toString();
                    return {
                        userid: lUserId,
                        room: lRoom,
                        type: lType,
                        title: lNotifyTitle,
                        message: lNotifyMessage,
                        time: lDateFormat,
                        optparam: lOptParam
                    };
                } else {
                    module.exports.throwHttpError(404, 'Check valid values: type', res);
                }
            } else {
                module.exports.throwHttpError(404, 'Check valid values: room', res);
            }
        } else {
            module.exports.throwHttpError(404, 'Check Parameter', res);
        }
    },
    //
    // Server index.html file (Overview)
    //
    serveIndex: function(res) {
        fs.readFile('./index.html', function(err, html) {
            // HTTP 404 when error
            if (err) {
                module.exports.throwHttpError(404, 'Not Found', res);
                // write index.html
            } else {
                res.write(html);
                res.end();
            }
        });
    },
    //
    // Server client.html file (testclient)
    //
    serveClient: function(res) {
        fs.readFile('./client.html', function(err, html) {
            // HTTP 404 when error
            if (err) {
                module.exports.throwHttpError(404, 'Not Found', res);
                // write index.html
            } else {
                res.write(html);
                res.end();
            }
        });
    },
    //
    // Delete user session older than 3 hours
    //
    deleteOldSessions: function() {
        setInterval(function() {
            localstore.deleteOldSessions(function(dbres, err) {
                if (dbres) {
                    // logging
                    prefs.doLog('Old Sessions deleted');
                }
                if (err) {
                    prefs.doLog('Error deleting User DB sessions: ' + err);
                }
            });
        }, 3600000);
    }
};
