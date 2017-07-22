// Send Websocket Notify
// Author: Daniel Hochleitner
// Version: 1.2

// global namespace
var sendNotifyWebsocket = {
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
  sendNotify: function() {
    // plugin attributes
    var daThis = this;
    var vAjaxIdentifier = daThis.action.ajaxIdentifier;
    var vUserIdItem = daThis.action.attribute01;
    var vRoomItem = daThis.action.attribute02;
    var vTypeItem = daThis.action.attribute03;
    var vTitleItem = daThis.action.attribute04;
    var vMessageItem = daThis.action.attribute05;
    var vOptParamItem = daThis.action.attribute06;
    var vShowWaitSpinner = sendNotifyWebsocket.parseBoolean(daThis.action.attribute07);
    var vLogging = sendNotifyWebsocket.parseBoolean(daThis.action.attribute08);
    var vSource = daThis.action.attribute09;
    var vUserId;
    var vRoom;
    var vType;
    var vTitle;
    var vMessage;
    var vOptParam;
    // item values
    if (vSource == 'ITEM') {
      vUserId = $v(vUserIdItem);
      vRoom = $v(vRoomItem);
      vType = $v(vTypeItem);
      vTitle = $v(vTitleItem);
      vMessage = $v(vMessageItem);
      vOptParam = $v(vOptParamItem);
    }
    // Logging
    if (vLogging) {
      console.log('sendNotify: Plugin AjaxIdentifier:', vAjaxIdentifier);
      console.log('sendNotify: Source:', vSource);
      console.log('sendNotify: Attribute User-ID Item:', vUserIdItem);
      console.log('sendNotify: Attribute Websocket Room Item:', vRoomItem);
      console.log('sendNotify: Attribute Notification Type Item:', vTypeItem);
      console.log('sendNotify: Attribute Notification Title Item:', vTitleItem);
      console.log('sendNotify: Attribute Notification Message Item:', vMessageItem);
      console.log('sendNotify: Attribute Optional Parameter Item:', vOptParamItem);
      console.log('sendNotify: Attribute User-ID Item:', vUserId);
      console.log('sendNotify: Attribute Websocket Room Value:', vRoom);
      console.log('sendNotify: Attribute Notification Type Value:', vType);
      console.log('sendNotify: Attribute Notification Title Value:', vTitle);
      console.log('sendNotify: Attribute Notification Message Value:', vMessage);
      console.log('sendNotify: Attribute Optional Parameter Value:', vOptParam);
      console.log('sendNotify: Attribute Show Wait Spinner:', vShowWaitSpinner);
      console.log('sendNotify: Attribute Logging:', vLogging);
    }
    // AJAX call send Notification
    // check parameter values
    if ((vUserId && vRoom && vType && vTitle && vMessage) || vSource == 'SQL') {
      // show spinner
      if (vShowWaitSpinner) {
        var lSpinner$ = apex.util.showSpinner('body');
      }
      // change defaults if all users
      var lRoom;
      if (vUserId === 'all') {
        lRoom = 'public';
      } else {
        lRoom = vRoom;
      }
      $s(vRoomItem, lRoom);
      // async server call
      apex.server.plugin(vAjaxIdentifier, {
        x01: vUserId,
        x02: lRoom,
        x03: vType,
        x04: vTitle,
        x05: vMessage,
        x06: vOptParam
      }, {
        dataType: 'html',
        // SUCESS function
        success: function() {
          // add apex event
          apex.event.trigger('body', 'ws-send-notify-success');
          // hide spinner
          if (vShowWaitSpinner) {
            lSpinner$.remove();
          }
        },
        // ERROR function
        error: function(xhr, pMessage) {
          // add apex event
          apex.event.trigger('body', 'ws-send-notify-error');
          // hide spinner
          if (vShowWaitSpinner) {
            lSpinner$.remove();
          }
        }
      });
    } else {
      // add apex event
      apex.event.trigger('body', 'ws-send-notify-missing-values');
    }
  }
};
