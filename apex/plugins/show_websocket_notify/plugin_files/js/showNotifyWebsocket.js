// Websocket Notify
// Author: Daniel Hochleitner
// Version: 1.2

// global namespace
var showNotifyWebsocket = {
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
  showNotify: function() {
    // plugin attributes
    var daThis = this;
    var data = daThis.data;
    var vNotifyIcon = daThis.action.attribute01;
    var vNotifyWaitTime = parseInt(daThis.action.attribute02);
    var vNotifyPosition = daThis.action.attribute03;
    var vLogging = showNotifyWebsocket.parseBoolean(daThis.action.attribute04);
    var vNotifyType = data.type;
    var vNotifyTitle = data.title;
    var vNotifyMessage = data.message;
    var vNotifyTime = data.time;
    var vNotifyOptParam = data.optparam;
    var vCallingEvent = daThis.browserEvent.type;
    // Logging
    if (vLogging) {
      console.log('showNotify: Attribute Notify Icon Class:', vNotifyIcon);
      console.log('showNotify: Attribute Notify Wait Time:', vNotifyWaitTime);
      console.log('showNotify: Attribute Notify Position:', vNotifyPosition);
      console.log('showNotify: Attribute Logging:', vLogging);
      console.log('showNotify: Websocket Data Object Notify Type:', vNotifyType);
      console.log('showNotify: Websocket Data Object Notify Title:', vNotifyTitle);
      console.log('showNotify: Websocket Data Object Notify Message:', vNotifyMessage);
      console.log('showNotify: Websocket Data Object Notify Time:', vNotifyTime);
      console.log('showNotify: Websocket Data Object Notify OptParam:', vNotifyOptParam);
      console.log('showNotify: Calling Event:', vCallingEvent);
    }
    // Alertify Notification
    var notification;
    alertify.set('notifier', 'position', vNotifyPosition);
    // info
    if (vNotifyType === 'info') {
      notification = alertify.message('<i class="fa ' + vNotifyIcon + '"></i> <strong>' + vNotifyTitle + '</strong> (' + vNotifyTime + '):<br>' + vNotifyMessage, vNotifyWaitTime);
      // success
    } else if (vNotifyType === 'success') {
      notification = alertify.success('<i class="fa ' + vNotifyIcon + '"></i> <strong>' + vNotifyTitle + '</strong> (' + vNotifyTime + '):<br>' + vNotifyMessage, vNotifyWaitTime);
      // warn
    } else if (vNotifyType === 'warn') {
      notification = alertify.warning('<i class="fa ' + vNotifyIcon + '"></i> <strong>' + vNotifyTitle + '</strong> (' + vNotifyTime + '):<br>' + vNotifyMessage, vNotifyWaitTime);
      // error
    } else if (vNotifyType === 'error') {
      notification = alertify.error('<i class="fa ' + vNotifyIcon + '"></i> <strong>' + vNotifyTitle + '</strong> (' + vNotifyTime + '):<br>' + vNotifyMessage, vNotifyWaitTime);
    }
    // add values to notification object
    notification.type = vNotifyType;
    notification.title = vNotifyTitle;
    notification.message = vNotifyMessage;
    notification.time = vNotifyTime;
    if (vNotifyOptParam) {
      notification.optparam = vNotifyOptParam;
    }
    // onclick
    notification.callback = function(isClicked) {
      if (isClicked) {
        setTimeout(function() {
          // private
          if (vCallingEvent.indexOf('private') > -1) {
            apex.event.trigger('body', 'ws-private-notify-clicked', notification);
            // public
          } else if (vCallingEvent.indexOf('public') > -1) {
            apex.event.trigger('body', 'ws-public-notify-clicked', notification);
          }
        }, 150);
      }
    };
  }
};
