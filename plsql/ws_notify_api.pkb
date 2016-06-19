CREATE OR REPLACE PACKAGE BODY ws_notify_api IS
  --
  -- API Package Body for Node Notify Websocket REST Calls
  --

  --
  /****************************************************************************
  * Purpose: Check Server response HTTP error (2XX Status codes)
  * Author:  Daniel Hochleitner
  * Created: 17.06.2016
  * Changed:
  ****************************************************************************/
  PROCEDURE check_error_http_status IS
    --
    l_status_code VARCHAR2(100);
    l_name        VARCHAR2(200);
    l_value       VARCHAR2(200);
    l_error_msg   CLOB;
    --
  BEGIN
    --
    -- get http headers from response
    FOR i IN 1 .. apex_web_service.g_headers.count LOOP
      l_status_code := apex_web_service.g_status_code;
      l_name        := apex_web_service.g_headers(i).name;
      l_value       := apex_web_service.g_headers(i).value;
      -- If not successful throw error
      IF l_status_code NOT LIKE '2%' THEN
        l_error_msg := 'Response HTTP Status NOT OK' || chr(10) || 'Name: ' ||
                       l_name || chr(10) || 'Value: ' || l_value || chr(10) ||
                       'Status Code: ' || l_status_code;
        raise_application_error(error_http_status_code,
                                l_error_msg);
      END IF;
    END LOOP;
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Insert your own exception handling here
      NULL;
      RAISE;
  END check_error_http_status;
  --
  /****************************************************************************
  * Purpose: Set HTTP headers for REST calls
  * Author:  Daniel Hochleitner
  * Created: 17.06.2016
  * Changed:
  ****************************************************************************/
  PROCEDURE set_http_headers(i_title   IN VARCHAR2,
                             i_message IN VARCHAR2) IS
    --
    l_user_agent VARCHAR2(100);
    l_server     ws_notify_api.g_ws_rest_host%TYPE;
    --
  BEGIN
    -- Clients Envs
    l_user_agent := 'Mozilla/5.0';
    l_server     := ws_notify_api.g_ws_rest_host;
    --
    -- set http headers
    -- Host
    apex_web_service.g_request_headers(1).name := 'Host';
    apex_web_service.g_request_headers(1).value := l_server;
    -- User-Agent
    apex_web_service.g_request_headers(2).name := 'User-Agent';
    apex_web_service.g_request_headers(2).value := l_user_agent;
    -- Title
    apex_web_service.g_request_headers(3).name := 'notify-title';
    apex_web_service.g_request_headers(3).value := i_title;
    -- Message
    apex_web_service.g_request_headers(4).name := 'notify-message';
    apex_web_service.g_request_headers(4).value := i_message;
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Insert your own exception handling here
      NULL;
      RAISE;
  END set_http_headers;
  --
  /****************************************************************************
  * Purpose: Send Websocket Notification over REST to connected users
  * Author:  Daniel Hochleitner
  * Created: 17.06.2016
  * Changed:
  ****************************************************************************/
  PROCEDURE do_rest_notify_user(i_userid   IN VARCHAR2,
                                i_room     IN VARCHAR2,
                                i_type     IN VARCHAR2,
                                i_title    IN VARCHAR2,
                                i_message  IN VARCHAR2,
                                i_optparam IN VARCHAR2 := NULL) IS
    --
    l_response       CLOB;
    l_url            VARCHAR2(200);
    l_http_auth_user ws_notify_api.g_ws_basic_auth_user%TYPE;
    l_http_auth_pwd  ws_notify_api.g_ws_basic_auth_pwd%TYPE;
    l_param_name     VARCHAR2(400);
    l_param_value    VARCHAR2(400);
    l_title          VARCHAR2(1000);
    l_message        VARCHAR2(4000);
    l_spacer         VARCHAR2(10) := '||';
    --
  BEGIN
    -- vars
    l_http_auth_user := ws_notify_api.g_ws_basic_auth_user;
    l_http_auth_pwd  := ws_notify_api.g_ws_basic_auth_pwd;
    l_title          := REPLACE(REPLACE(substr(i_title,
                                               1,
                                               1000),
                                        chr(10),
                                        ' '),
                                chr(13),
                                ' ');
    l_message        := REPLACE(REPLACE(substr(i_message,
                                               1,
                                               4000),
                                        chr(10),
                                        ' '),
                                chr(13),
                                ' ');
    --
    -- set HTTP Header (with title und message)
    ws_notify_api.set_http_headers(i_title   => l_title,
                                   i_message => l_message);
    -- build request params
    IF i_optparam IS NULL THEN
      l_param_name  := 'userid' || l_spacer || 'room' || l_spacer || 'type';
      l_param_value := lower(i_userid) || l_spacer || lower(i_room) ||
                       l_spacer || lower(i_type);
    ELSE
      l_param_name  := 'userid' || l_spacer || 'room' || l_spacer || 'type' ||
                       l_spacer || 'optparam';
      l_param_value := lower(i_userid) || l_spacer || lower(i_room) ||
                       l_spacer || lower(i_type) || l_spacer || i_optparam;
    END IF;
    -- URL
    l_url := ws_notify_api.g_ws_rest_base_url;
    -- REST call
    -- HTTP
    IF lower(ws_notify_api.g_ws_rest_proto) = 'http' THEN
      l_response := apex_web_service.make_rest_request(p_url         => l_url,
                                                       p_http_method => 'GET',
                                                       p_username    => l_http_auth_user,
                                                       p_password    => l_http_auth_pwd,
                                                       p_parm_name   => apex_util.string_to_table(l_param_name,
                                                                                                  l_spacer),
                                                       p_parm_value  => apex_util.string_to_table(l_param_value,
                                                                                                  l_spacer));
      -- HTTPS
    ELSIF lower(ws_notify_api.g_ws_rest_proto) = 'https' THEN
      l_response := apex_web_service.make_rest_request(p_url         => l_url,
                                                       p_http_method => 'GET',
                                                       p_username    => l_http_auth_user,
                                                       p_password    => l_http_auth_pwd,
                                                       p_parm_name   => apex_util.string_to_table(l_param_name,
                                                                                                  l_spacer),
                                                       p_parm_value  => apex_util.string_to_table(l_param_value,
                                                                                                  l_spacer),
                                                       p_wallet_path => ws_notify_api.g_ssl_wallet_path,
                                                       p_wallet_pwd  => ws_notify_api.g_ssl_wallet_pwd);
    END IF;
    --
    -- check http status (2XX)
    ws_notify_api.check_error_http_status;
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Insert your own exception handling here
      NULL;
      RAISE;
  END do_rest_notify_user;
  --
  /****************************************************************************
  * Purpose: Send Websocket Notification to User / Room: Private / Type: Info
  * Author:  Daniel Hochleitner
  * Created: 17.06.2016
  * Changed:
  ****************************************************************************/
  PROCEDURE do_notify_user_private_info(i_userid   IN VARCHAR2,
                                        i_title    IN VARCHAR2,
                                        i_message  IN VARCHAR2,
                                        i_optparam IN VARCHAR2 := NULL) IS
    --
  BEGIN
    -- REST call
    ws_notify_api.do_rest_notify_user(i_userid   => i_userid,
                                      i_room     => 'private',
                                      i_type     => 'info',
                                      i_title    => i_title,
                                      i_message  => i_message,
                                      i_optparam => i_optparam);
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Insert your own exception handling here
      NULL;
      RAISE;
  END do_notify_user_private_info;
  --
  /****************************************************************************
  * Purpose: Send Websocket Notification to User / Room: Private / Type: Success
  * Author:  Daniel Hochleitner
  * Created: 17.06.2016
  * Changed:
  ****************************************************************************/
  PROCEDURE do_notify_user_private_success(i_userid   IN VARCHAR2,
                                           i_title    IN VARCHAR2,
                                           i_message  IN VARCHAR2,
                                           i_optparam IN VARCHAR2 := NULL) IS
    --
  BEGIN
    -- REST call
    ws_notify_api.do_rest_notify_user(i_userid   => i_userid,
                                      i_room     => 'private',
                                      i_type     => 'success',
                                      i_title    => i_title,
                                      i_message  => i_message,
                                      i_optparam => i_optparam);
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Insert your own exception handling here
      NULL;
      RAISE;
  END do_notify_user_private_success;
  --
  /****************************************************************************
  * Purpose: Send Websocket Notification to User / Room: Private / Type: Warn
  * Author:  Daniel Hochleitner
  * Created: 17.06.2016
  * Changed:
  ****************************************************************************/
  PROCEDURE do_notify_user_private_warn(i_userid   IN VARCHAR2,
                                        i_title    IN VARCHAR2,
                                        i_message  IN VARCHAR2,
                                        i_optparam IN VARCHAR2 := NULL) IS
    --
  BEGIN
    -- REST call
    ws_notify_api.do_rest_notify_user(i_userid   => i_userid,
                                      i_room     => 'private',
                                      i_type     => 'warn',
                                      i_title    => i_title,
                                      i_message  => i_message,
                                      i_optparam => i_optparam);
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Insert your own exception handling here
      NULL;
      RAISE;
  END do_notify_user_private_warn;
  --
  /****************************************************************************
  * Purpose: Send Websocket Notification to User / Room: Private / Type: Error
  * Author:  Daniel Hochleitner
  * Created: 17.06.2016
  * Changed:
  ****************************************************************************/
  PROCEDURE do_notify_user_private_error(i_userid   IN VARCHAR2,
                                         i_title    IN VARCHAR2,
                                         i_message  IN VARCHAR2,
                                         i_optparam IN VARCHAR2 := NULL) IS
    --
  BEGIN
    -- REST call
    ws_notify_api.do_rest_notify_user(i_userid   => i_userid,
                                      i_room     => 'private',
                                      i_type     => 'error',
                                      i_title    => i_title,
                                      i_message  => i_message,
                                      i_optparam => i_optparam);
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Insert your own exception handling here
      NULL;
      RAISE;
  END do_notify_user_private_error;
  --
  /****************************************************************************
  * Purpose: Send Websocket Notification to User / Room: Public / Type: Info
  * Author:  Daniel Hochleitner
  * Created: 17.06.2016
  * Changed:
  ****************************************************************************/
  PROCEDURE do_notify_user_public_info(i_userid   IN VARCHAR2,
                                       i_title    IN VARCHAR2,
                                       i_message  IN VARCHAR2,
                                       i_optparam IN VARCHAR2 := NULL) IS
    --
  BEGIN
    -- REST call
    ws_notify_api.do_rest_notify_user(i_userid   => i_userid,
                                      i_room     => 'public',
                                      i_type     => 'info',
                                      i_title    => i_title,
                                      i_message  => i_message,
                                      i_optparam => i_optparam);
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Insert your own exception handling here
      NULL;
      RAISE;
  END do_notify_user_public_info;
  --
  /****************************************************************************
  * Purpose: Send Websocket Notification to User / Room: Public / Type: Success
  * Author:  Daniel Hochleitner
  * Created: 17.06.2016
  * Changed:
  ****************************************************************************/
  PROCEDURE do_notify_user_public_success(i_userid   IN VARCHAR2,
                                          i_title    IN VARCHAR2,
                                          i_message  IN VARCHAR2,
                                          i_optparam IN VARCHAR2 := NULL) IS
    --
  BEGIN
    -- REST call
    ws_notify_api.do_rest_notify_user(i_userid   => i_userid,
                                      i_room     => 'public',
                                      i_type     => 'success',
                                      i_title    => i_title,
                                      i_message  => i_message,
                                      i_optparam => i_optparam);
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Insert your own exception handling here
      NULL;
      RAISE;
  END do_notify_user_public_success;
  --
  /****************************************************************************
  * Purpose: Send Websocket Notification to User / Room: Public / Type: Warn
  * Author:  Daniel Hochleitner
  * Created: 17.06.2016
  * Changed:
  ****************************************************************************/
  PROCEDURE do_notify_user_public_warn(i_userid   IN VARCHAR2,
                                       i_title    IN VARCHAR2,
                                       i_message  IN VARCHAR2,
                                       i_optparam IN VARCHAR2 := NULL) IS
    --
  BEGIN
    -- REST call
    ws_notify_api.do_rest_notify_user(i_userid   => i_userid,
                                      i_room     => 'public',
                                      i_type     => 'warn',
                                      i_title    => i_title,
                                      i_message  => i_message,
                                      i_optparam => i_optparam);
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Insert your own exception handling here
      NULL;
      RAISE;
  END do_notify_user_public_warn;
  --
  /****************************************************************************
  * Purpose: Send Websocket Notification to User / Room: Public / Type: Error
  * Author:  Daniel Hochleitner
  * Created: 17.06.2016
  * Changed:
  ****************************************************************************/
  PROCEDURE do_notify_user_public_error(i_userid   IN VARCHAR2,
                                        i_title    IN VARCHAR2,
                                        i_message  IN VARCHAR2,
                                        i_optparam IN VARCHAR2 := NULL) IS
    --
  BEGIN
    -- REST call
    ws_notify_api.do_rest_notify_user(i_userid   => i_userid,
                                      i_room     => 'public',
                                      i_type     => 'error',
                                      i_title    => i_title,
                                      i_message  => i_message,
                                      i_optparam => i_optparam);
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Insert your own exception handling here
      NULL;
      RAISE;
  END do_notify_user_public_error;
  --
  /****************************************************************************
  * Purpose: Send Websocket Notification to all Users / Room: Public / Type: Info
  * Author:  Daniel Hochleitner
  * Created: 17.06.2016
  * Changed:
  ****************************************************************************/
  PROCEDURE do_notify_all_public_info(i_title    IN VARCHAR2,
                                      i_message  IN VARCHAR2,
                                      i_optparam IN VARCHAR2 := NULL) IS
    --
  BEGIN
    -- REST call
    ws_notify_api.do_rest_notify_user(i_userid   => 'all',
                                      i_room     => 'public',
                                      i_type     => 'info',
                                      i_title    => i_title,
                                      i_message  => i_message,
                                      i_optparam => i_optparam);
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Insert your own exception handling here
      NULL;
      RAISE;
  END do_notify_all_public_info;
  --
  /****************************************************************************
  * Purpose: Send Websocket Notification to all Users / Room: Public / Type: Success
  * Author:  Daniel Hochleitner
  * Created: 17.06.2016
  * Changed:
  ****************************************************************************/
  PROCEDURE do_notify_all_public_success(i_title    IN VARCHAR2,
                                         i_message  IN VARCHAR2,
                                         i_optparam IN VARCHAR2 := NULL) IS
    --
  BEGIN
    -- REST call
    ws_notify_api.do_rest_notify_user(i_userid   => 'all',
                                      i_room     => 'public',
                                      i_type     => 'success',
                                      i_title    => i_title,
                                      i_message  => i_message,
                                      i_optparam => i_optparam);
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Insert your own exception handling here
      NULL;
      RAISE;
  END do_notify_all_public_success;
  --
  /****************************************************************************
  * Purpose: Send Websocket Notification to all Users / Room: Public / Type: Warn
  * Author:  Daniel Hochleitner
  * Created: 17.06.2016
  * Changed:
  ****************************************************************************/
  PROCEDURE do_notify_all_public_warn(i_title    IN VARCHAR2,
                                      i_message  IN VARCHAR2,
                                      i_optparam IN VARCHAR2 := NULL) IS
    --
  BEGIN
    -- REST call
    ws_notify_api.do_rest_notify_user(i_userid   => 'all',
                                      i_room     => 'public',
                                      i_type     => 'warn',
                                      i_title    => i_title,
                                      i_message  => i_message,
                                      i_optparam => i_optparam);
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Insert your own exception handling here
      NULL;
      RAISE;
  END do_notify_all_public_warn;
  --
  /****************************************************************************
  * Purpose: Send Websocket Notification to all Users / Room: Public / Type: Error
  * Author:  Daniel Hochleitner
  * Created: 17.06.2016
  * Changed:
  ****************************************************************************/
  PROCEDURE do_notify_all_public_error(i_title    IN VARCHAR2,
                                       i_message  IN VARCHAR2,
                                       i_optparam IN VARCHAR2 := NULL) IS
    --
  BEGIN
    -- REST call
    ws_notify_api.do_rest_notify_user(i_userid   => 'all',
                                      i_room     => 'public',
                                      i_type     => 'error',
                                      i_title    => i_title,
                                      i_message  => i_message,
                                      i_optparam => i_optparam);
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Insert your own exception handling here
      NULL;
      RAISE;
  END do_notify_all_public_error;
  --
END ws_notify_api;
/
