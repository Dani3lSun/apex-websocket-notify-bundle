var http = require("http");
var https = require('https');
var url = require("url");
var fs = require('fs');
var io = require('socket.io');
var util = require('util');
var srvHelper = require("./srvhelper");
var localstore = require("./localstore");
var prefs = require("./prefs");
var serverPrefs = prefs.readPrefs('server');
var socketPrefs = prefs.readPrefs('socket');
var ip = serverPrefs.ip;
var port = serverPrefs.port;
var sslKeyPath = serverPrefs.sslKeyPath;
var sslCertPath = serverPrefs.sslCertPath;
var isPrivate = socketPrefs.private;
var isPublic = socketPrefs.public;
var socketAuthToken = socketPrefs.authToken;
var server;
// Create HTTP Server
// SSL HTTP
if ((sslKeyPath) && (sslCertPath)) {
    var sslOptions = {
        key: fs.readFileSync(sslKeyPath),
        cert: fs.readFileSync(sslCertPath)
    };
    server = https.createServer(sslOptions, function(req, res) {
        var lItems;
        var lUserId;
        var lRoom;
        var lTitle;
        var lMessage;
        var lTime;
        var lOptParam;
        var lType;
        var lJsonString;
        // parse URL and Path
        var parsedUrl = url.parse(req.url, true);
        var path = parsedUrl.pathname;
        var fullPath = parsedUrl.path;
        // logging IP and path
        prefs.doLog('Remote IP:', req.connection.remoteAddress);
        prefs.doLog('Path:', path);
        prefs.doLog('Full Path:', fullPath);
        prefs.doLog('User Agent:', req.headers['user-agent']);
        // HTTP Basic Auth
        if (srvHelper.doBasicAuth(req, res)) {
            // index html with overview of services
            if (path == '/' && fullPath.length == path.length) {
                srvHelper.serveIndex(res);
                // Test client
            } else if (path == '/testclient') {
                srvHelper.serveClient(res);
                // Path notifyuser get interface
            } else if (path == '/notifyuser') {
                lItems = srvHelper.getNotifyInfo(req, res);
                if (lItems) {
                    lUserId = lItems.userid;
                    lRoom = lItems.room;
                    lType = lItems.type;
                    lTitle = lItems.title;
                    lMessage = lItems.message;
                    lTime = lItems.time;
                    lOptParam = lItems.optparam;
                    // logging
                    prefs.doLog(lUserId + ' ' + lRoom + ' ' + lType + ' ' + lTitle + ' ' + lMessage + ' ' + lOptParam + ' ' + lTime);
                    // call notify
                    socketio.sendNotify(lUserId, lRoom, lType, lTitle, lMessage, lOptParam, lTime, function() {
                        res.end();
                    });
                }
                // socket status
            } else if (path == '/status') {
                res.writeHead(200, {
                    "Content-Type": "text/plain"
                });
                socketio.getSocketInfo(function(returnText) {
                    lStatusText = returnText;
                    res.write(lStatusText);
                    res.end();
                });
                // path not found
            } else {
                srvHelper.throwHttpError(404, 'Not Found', res);
            }
        }
    });
    // Standard HTTP
} else {
    server = http.createServer(function(req, res) {
        var lItems;
        var lUserId;
        var lType;
        var lRoom;
        var lTitle;
        var lMessage;
        var lTime;
        var lOptParam;
        var lStatusText;
        // parse URL and Path
        var parsedUrl = url.parse(req.url, true);
        var path = parsedUrl.pathname;
        var fullPath = parsedUrl.path;
        // logging IP and path
        prefs.doLog('Remote IP:', req.connection.remoteAddress);
        prefs.doLog('Path:', path);
        prefs.doLog('Full Path:', fullPath);
        prefs.doLog('User Agent:', req.headers['user-agent']);
        // HTTP Basic Auth
        if (srvHelper.doBasicAuth(req, res)) {
            // index html with overview of services
            if (path == '/' && fullPath.length == path.length) {
                srvHelper.serveIndex(res);
                // Test client
            } else if (path == '/testclient') {
                srvHelper.serveClient(res);
                // Path notifyuser get interface
            } else if (path == '/notifyuser') {
                lItems = srvHelper.getNotifyInfo(req, res);
                if (lItems) {
                    lUserId = lItems.userid;
                    lRoom = lItems.room;
                    lType = lItems.type;
                    lTitle = lItems.title;
                    lMessage = lItems.message;
                    lTime = lItems.time;
                    lOptParam = lItems.optparam;
                    // logging
                    prefs.doLog(lUserId + ' ' + lRoom + ' ' + lType + ' ' + lTitle + ' ' + lMessage + ' ' + lOptParam + ' ' + lTime);
                    // call notify
                    socketio.sendNotify(lUserId, lRoom, lType, lTitle, lMessage, lOptParam, lTime, function() {
                        res.end();
                    });
                }
                // socket status
            } else if (path == '/status') {
                res.writeHead(200, {
                    "Content-Type": "text/plain"
                });
                socketio.getSocketInfo(function(returnText) {
                    lStatusText = returnText;
                    res.write(lStatusText);
                    res.end();
                });
                // path not found
            } else {
                srvHelper.throwHttpError(404, 'Not Found', res);
            }
        }
    });
}
server.listen(port, ip);
// Log started HTTP Server
if ((sslKeyPath) && (sslCertPath)) {
    prefs.doLog("HTTPS Server listening on " + ip + ":" + port);
} else {
    prefs.doLog("HTTP Server listening on " + ip + ":" + port);
}
//
// Socket.io
//
var listener = io.listen(server);
if (isPrivate) {
    var ioPrivate = listener.of('/private');
}
if (isPublic) {
    var ioPublic = listener.of('/public');
}
var socketio = {
    // CONNECT ALL SOCKETS
    connectSockets: function() {
        // Private connect
        if (isPrivate) {
            ioPrivate.on('connection', function(socket) {
                var userid = socket.handshake.query.userid;
                var authToken = socket.handshake.query.authtoken;
                // check authToken
                if (authToken == socketAuthToken) {
                    // token success
                    socket.userid = userid;
                    // logging
                    prefs.doLog(userid + ' connected to Private');
                    // save session
                    localstore.saveUserSession(userid, 'private', socket.id, function() {
                        // logging
                        prefs.doLog(userid + ' private session saved in DB');
                    });
                } else {
                    // token error
                    // logging
                    prefs.doLog(userid + ' with wrong authToken: ' + authToken);
                    // disconnect
                    socket.disconnect();
                }
            });
        }
        // Public connect
        if (isPublic) {
            ioPublic.on('connection', function(socket) {
                var userid = socket.handshake.query.userid;
                var authToken = socket.handshake.query.authtoken;
                // check authToken
                if (authToken == socketAuthToken) {
                    // token success
                    socket.userid = userid;
                    // logging
                    prefs.doLog(userid + ' connected to Public');
                    // save session
                    localstore.saveUserSession(userid, 'public', socket.id, function() {
                        // logging
                        prefs.doLog(userid + ' public session saved in DB');
                    });
                } else {
                    // token error
                    // logging
                    prefs.doLog(userid + ' with wrong authToken: ' + authToken);
                    // disconnect
                    socket.disconnect();
                }
            });
        }
    },
    // SEND MESSAGE TO CLIENTS
    sendNotify: function(pUserId, pRoom, pType, pTitle, pMessage, pOptParam, pTime, callback) {
        // get user session
        localstore.getUserSession(pUserId, pRoom, function(dbres, err) {
            if (dbres) {
                dbres.forEach(function(dbItem) {
                    lSessionid = dbItem.session;
                    // logging
                    prefs.doLog(lSessionid);
                    // private
                    if (pRoom === 'private') {
                        if (isPrivate) {
                            ioPrivate.to(lSessionid).emit('message', {
                                'type': pType,
                                'title': pTitle,
                                'message': pMessage,
                                'time': pTime,
                                'optparam': pOptParam
                            });
                        }
                        // public
                    } else if (pRoom === 'public') {
                        if (isPublic) {
                            ioPublic.to(lSessionid).emit('message', {
                                'type': pType,
                                'title': pTitle,
                                'message': pMessage,
                                'time': pTime,
                                'optparam': pOptParam
                            });
                        }
                    }
                });
            }
            if (err) {
                prefs.doLog(pUserId, 'Error receiving User DB session: ' + err);
            }
        });
        callback();
    },
    // GET SOCKET INFO
    getSocketInfo: function(callback) {
        var lReturnText;
        var lCount;
        // socket counter
        lReturnText = 'CONNECTED CLIENTS COUNTER:' + '\n';
        // private
        if (isPrivate) {
            lCount = Object.keys(ioPrivate.connected).length;
            lReturnText = lReturnText + 'Connected to Private: ' + lCount + '\n';
        }
        // public
        if (isPublic) {
            lCount = Object.keys(ioPublic.connected).length;
            lReturnText = lReturnText + 'Connected to Public: ' + lCount + '\n' + '\n';
        }
        // DB stats
        lReturnText = lReturnText + 'DATABASE STATS:' + '\n';
        // DB stats info
        localstore.getDbStats(function(dbres, err) {
            if (dbres) {
                dbres.forEach(function(dbItem) {
                    lReturnText = lReturnText + dbItem.room + ': ' + dbItem.counter + ' entries' + '\n';
                });
            }
            if (err) {
                prefs.doLog(pUserId, 'Error receiving DB stats: ' + err);
            }
            callback(lReturnText);
        });
        // logging
        prefs.doLog(lReturnText);
    }
};
// connect sockets
socketio.connectSockets();
// delete user session older than 3 hours
srvHelper.deleteOldSessions();
