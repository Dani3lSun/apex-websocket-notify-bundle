CREATE OR REPLACE PACKAGE ws_notify_api IS
  --
  -- API Package Spec for Node Notify Websocket REST Calls
  --

  --
  -- Websocket REST Call defaults
  --
  g_ws_rest_host     VARCHAR2(50) := 'localhost';
  g_ws_rest_port     VARCHAR2(50) := '8080';
  g_ws_rest_path     VARCHAR2(50) := '/notifyuser';
  g_ws_rest_proto    VARCHAR2(50) := 'http'; -- http or https
  g_ws_rest_base_url VARCHAR2(200) := ws_notify_api.g_ws_rest_proto ||
                                      '://' || ws_notify_api.g_ws_rest_host || ':' ||
                                      ws_notify_api.g_ws_rest_port ||
                                      ws_notify_api.g_ws_rest_path;
  -- security defaults
  g_ws_basic_auth_user VARCHAR2(100) := '';
  g_ws_basic_auth_pwd  VARCHAR2(100) := '';
  -- wallet info: only if g_ws_rest_proto = https
  g_ssl_wallet_path VARCHAR2(200) := 'file:/home/oracle/wallet'; -- set your local wallet path
  g_ssl_wallet_pwd  VARCHAR2(100) := 'pwd'; -- set your wallet password
  --
  -- Exceptions Error Codes
  --
  error_http_status_code CONSTANT NUMBER := -20002;
  --
  -- Public Functions and Procedures
  --

  -- Send Websocket Notification over REST to connected users
  -- #param i_userid
  -- #param i_room ("private" or "public")
  -- #param i_type (info, success, warn, error)
  -- #param i_title
  -- #param i_message
  -- #param i_optparam (Optional Parameter String)
  PROCEDURE do_rest_notify_user(i_userid   IN VARCHAR2,
                                i_room     IN VARCHAR2,
                                i_type     IN VARCHAR2,
                                i_title    IN VARCHAR2,
                                i_message  IN VARCHAR2,
                                i_optparam IN VARCHAR2 := NULL);
  --
  -- Send Websocket Notification to User / Room: Private / Type: Info
  -- #param i_userid
  -- #param i_title
  -- #param i_message
  -- #param i_optparam (Optional Parameter String)
  PROCEDURE do_notify_user_private_info(i_userid   IN VARCHAR2,
                                        i_title    IN VARCHAR2,
                                        i_message  IN VARCHAR2,
                                        i_optparam IN VARCHAR2 := NULL);
  --
  -- Send Websocket Notification to User / Room: Private / Type: Success
  -- #param i_userid
  -- #param i_title
  -- #param i_message
  -- #param i_optparam (Optional Parameter String)
  PROCEDURE do_notify_user_private_success(i_userid   IN VARCHAR2,
                                           i_title    IN VARCHAR2,
                                           i_message  IN VARCHAR2,
                                           i_optparam IN VARCHAR2 := NULL);
  --
  -- Send Websocket Notification to User / Room: Private / Type: Warn
  -- #param i_userid
  -- #param i_title
  -- #param i_message
  -- #param i_optparam (Optional Parameter String)
  PROCEDURE do_notify_user_private_warn(i_userid   IN VARCHAR2,
                                        i_title    IN VARCHAR2,
                                        i_message  IN VARCHAR2,
                                        i_optparam IN VARCHAR2 := NULL);
  --
  -- Send Websocket Notification to User / Room: Private / Type: Error
  -- #param i_userid
  -- #param i_title
  -- #param i_message
  -- #param i_optparam (Optional Parameter String)
  PROCEDURE do_notify_user_private_error(i_userid   IN VARCHAR2,
                                         i_title    IN VARCHAR2,
                                         i_message  IN VARCHAR2,
                                         i_optparam IN VARCHAR2 := NULL);
  --
  -- Send Websocket Notification to User / Room: Public / Type: Info
  -- #param i_userid
  -- #param i_title
  -- #param i_message
  -- #param i_optparam (Optional Parameter String)
  PROCEDURE do_notify_user_public_info(i_userid   IN VARCHAR2,
                                       i_title    IN VARCHAR2,
                                       i_message  IN VARCHAR2,
                                       i_optparam IN VARCHAR2 := NULL);
  --
  -- Send Websocket Notification to User / Room: Public / Type: Success
  -- #param i_userid
  -- #param i_title
  -- #param i_message
  -- #param i_optparam (Optional Parameter String)
  PROCEDURE do_notify_user_public_success(i_userid   IN VARCHAR2,
                                          i_title    IN VARCHAR2,
                                          i_message  IN VARCHAR2,
                                          i_optparam IN VARCHAR2 := NULL);
  --
  -- Send Websocket Notification to User / Room: Public / Type: Warn
  -- #param i_userid
  -- #param i_title
  -- #param i_message
  -- #param i_optparam (Optional Parameter String)
  PROCEDURE do_notify_user_public_warn(i_userid   IN VARCHAR2,
                                       i_title    IN VARCHAR2,
                                       i_message  IN VARCHAR2,
                                       i_optparam IN VARCHAR2 := NULL);
  --
  -- Send Websocket Notification to User / Room: Public / Type: Error
  -- #param i_userid
  -- #param i_title
  -- #param i_message
  -- #param i_optparam (Optional Parameter String)
  PROCEDURE do_notify_user_public_error(i_userid   IN VARCHAR2,
                                        i_title    IN VARCHAR2,
                                        i_message  IN VARCHAR2,
                                        i_optparam IN VARCHAR2 := NULL);
  --
  -- Send Websocket Notification to all Users / Room: Public / Type: Info
  -- #param i_title
  -- #param i_message
  -- #param i_optparam (Optional Parameter String)
  PROCEDURE do_notify_all_public_info(i_title    IN VARCHAR2,
                                      i_message  IN VARCHAR2,
                                      i_optparam IN VARCHAR2 := NULL);
  --
  -- Send Websocket Notification to all Users / Room: Public / Type: Success
  -- #param i_title
  -- #param i_message
  -- #param i_optparam (Optional Parameter String)
  PROCEDURE do_notify_all_public_success(i_title    IN VARCHAR2,
                                         i_message  IN VARCHAR2,
                                         i_optparam IN VARCHAR2 := NULL);
  --
  -- Send Websocket Notification to all Users / Room: Public / Type: Warn
  -- #param i_title
  -- #param i_message
  -- #param i_optparam (Optional Parameter String)
  PROCEDURE do_notify_all_public_warn(i_title    IN VARCHAR2,
                                      i_message  IN VARCHAR2,
                                      i_optparam IN VARCHAR2 := NULL);
  --
  -- Send Websocket Notification to all Users / Room: Public / Type: Error
  -- #param i_title
  -- #param i_message
  -- #param i_optparam (Optional Parameter String)
  PROCEDURE do_notify_all_public_error(i_title    IN VARCHAR2,
                                       i_message  IN VARCHAR2,
                                       i_optparam IN VARCHAR2 := NULL);
END ws_notify_api;
/
