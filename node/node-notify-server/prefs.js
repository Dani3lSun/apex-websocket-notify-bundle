//
// Local Preferences functions
//
var fs = require('fs');
var jsonObject;
//
module.exports = {
    // read prefs from local json file
    readPrefs: function(pType) {
        if (!(jsonObject)) {
            var data = fs.readFileSync('./prefs.json');
            jsonObject = JSON.parse(data);
        }
        if (pType == 'server') {
            var ip = jsonObject.server.ip;
            var port = jsonObject.server.port;
            var authUser = jsonObject.server.authUser;
            var authPwd = jsonObject.server.authPwd;
            var sslKeyPath = jsonObject.server.sslKeyPath;
            var sslCertPath = jsonObject.server.sslCertPath;
            var logging = jsonObject.server.logging;
            return {
                ip: ip,
                port: port,
                authUser: authUser,
                authPwd: authPwd,
                sslKeyPath: sslKeyPath,
                sslCertPath: sslCertPath,
                logging: logging
            };
        } else if (pType == 'socket') {
            var lPrivate = jsonObject.socket.private;
            var lPublic = jsonObject.socket.public;
            var lAuthToken = jsonObject.socket.authToken;
            return {
                private: lPrivate,
                public: lPublic,
                authToken: lAuthToken
            };
        }
    },
    // central logging function
    doLog: function(pMsg, pObj1, pObj2) {
        var serverPrefs = module.exports.readPrefs('server');
        var logging = serverPrefs.logging;
        if (logging) {
            if (pMsg && pObj1 && pObj2) {
                console.log(pMsg, pObj1, pObj2);
            } else if (pMsg && pObj1) {
                console.log(pMsg, pObj1);
            } else if (pMsg) {
                console.log(pMsg);
            }
        }
    }
};
