// Init Websocket Notify Connection
// Author: Daniel Hochleitner
// Version: 1.2

// global namespace
var initNotifyWebsocket = {
  // parse string to boolean
  parseBoolean: function(pString) {
    var pBoolean;
    if (pString.toLowerCase() == 'true') {
      pBoolean = true;
    }
    if (pString.toLowerCase() == 'false') {
      pBoolean = false;
    }
    if (!(pString.toLowerCase() == 'true') && !(pString.toLowerCase() == 'false')) {
      pBoolean = undefined;
    }
    return pBoolean;
  },
  // function that gets called from plugin
  initConnection: function() {
    // plugin attributes
    var daThis = this;
    var vUseSSL = parseInt(daThis.action.attribute01);
    var vServerHostname = daThis.action.attribute02;
    var vServerPort = parseInt(daThis.action.attribute03);
    var vWsRoom = daThis.action.attribute04;
    var vWsUserId = daThis.action.attribute05;
    var vWsAuthToken = daThis.action.attribute06;
    var vLogging = initNotifyWebsocket.parseBoolean(daThis.action.attribute07);
    // Logging
    if (vLogging) {
      console.log('initConnection: Attribute Use SSL:', vUseSSL);
      console.log('initConnection: Attribute Server Hostname/IP:', vServerHostname);
      console.log('initConnection: Attribute Server Port:', vServerPort);
      console.log('initConnection: Attribute Websocket Type/Room:', vWsRoom);
      console.log('initConnection: Attribute Websocket User-ID:', vWsUserId);
      console.log('initConnection: Attribute Websocket Auth-Token:', vWsAuthToken);
      console.log('initConnection: Attribute Logging:', vLogging);
    }
    // Websocket connection
    var serverBaseUrl;
    if (vUseSSL == 1) {
      serverBaseUrl = 'https://' + vServerHostname + ':' + vServerPort;
    } else if (vUseSSL === 0) {
      serverBaseUrl = 'http://' + vServerHostname + ':' + vServerPort;
    }
    // private Websocket
    if (vWsRoom === 'private') {
      // Login to socket.io services
      var privateSocket = io.connect(serverBaseUrl + '/private', {
        query: "userid=" + vWsUserId + "&authtoken=" + vWsAuthToken
      });
      // Events
      // incoming message
      privateSocket.on('message', function(data) {
        // Trigger Event
        apex.event.trigger('body', 'ws-private-message', data);
        // Logging
        if (vLogging) {
          console.log('private-socket-message');
          console.log('type', data.type);
          console.log('title', data.title);
          console.log('message', data.message);
          console.log('time', data.time);
          console.log('optparam', data.optparam);
        }
      });
      // Connect
      privateSocket.on('connect', function() {
        // Trigger Event
        apex.event.trigger('body', 'ws-private-connect-success');
      });
      // Error
      privateSocket.on('error', function() {
        // Trigger Event
        apex.event.trigger('body', 'ws-private-connect-error');
      });
      // Disconnect
      privateSocket.on('disconnect', function() {
        // Trigger Event
        apex.event.trigger('body', 'ws-private-disconnect');
        // Reconnect
        var privateSocket = io.connect(serverBaseUrl + '/private', {
          query: "userid=" + vWsUserId + "&authtoken=" + vWsAuthToken
        });
      });
      // public Websocket
    } else if (vWsRoom === 'public') {
      // Login to socket.io services
      var publicSocket = io.connect(serverBaseUrl + '/public', {
        query: "userid=" + vWsUserId + "&authtoken=" + vWsAuthToken
      });
      // Events
      // incoming message
      publicSocket.on('message', function(data) {
        // Trigger Event
        apex.event.trigger('body', 'ws-public-message', data);
        // Logging
        if (vLogging) {
          console.log('public-socket-message');
          console.log('type', data.type);
          console.log('title', data.title);
          console.log('message', data.message);
          console.log('time', data.time);
          console.log('optparam', data.optparam);
        }
      });
      // Connect
      publicSocket.on('connect', function() {
        // Trigger Event
        apex.event.trigger('body', 'ws-public-connect-success');
      });
      // Error
      publicSocket.on('error', function() {
        // Trigger Event
        apex.event.trigger('body', 'ws-public-connect-error');
      });
      // Disconnect
      publicSocket.on('disconnect', function() {
        // Trigger Event
        apex.event.trigger('body', 'ws-public-disconnect');
        // Reconnect
        var publicSocket = io.connect(serverBaseUrl + '/public', {
          query: "userid=" + vWsUserId + "&authtoken=" + vWsAuthToken
        });
      });
    }
  }
};
