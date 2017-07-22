set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050000 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2013.01.01'
,p_release=>'5.0.4.00.12'
,p_default_workspace_id=>49962301308291332
,p_default_application_id=>850
,p_default_owner=>'WSNOTIFY'
);
end;
/
prompt --application/ui_types
begin
null;
end;
/
prompt --application/shared_components/plugins/dynamic_action/de_danielh_sendwsnotify
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(19816233540510881)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'DE.DANIELH.SENDWSNOTIFY'
,p_display_name=>'Send Websocket Notify'
,p_category=>'EXECUTE'
,p_supported_ui_types=>'DESKTOP'
,p_javascript_file_urls=>'#PLUGIN_FILES#sendNotifyWebsocket#MIN#.js'
,p_plsql_code=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'/*-------------------------------------',
' * Send Websocket Notify',
' * Version: 1.2 (22.07.2017)',
' * Author:  Daniel Hochleitner',
' *-------------------------------------',
'*/',
'FUNCTION render_send_ws_notify(p_dynamic_action IN apex_plugin.t_dynamic_action,',
'                               p_plugin         IN apex_plugin.t_plugin)',
'  RETURN apex_plugin.t_dynamic_action_render_result IS',
'  --',
'  -- plugin attributes',
'  l_result        apex_plugin.t_dynamic_action_render_result;',
'  l_userid_item   VARCHAR2(100) := p_dynamic_action.attribute_01;',
'  l_ws_room_item  VARCHAR2(100) := p_dynamic_action.attribute_02;',
'  l_ws_type_item  VARCHAR2(100) := p_dynamic_action.attribute_03;',
'  l_title_item    VARCHAR2(100) := p_dynamic_action.attribute_04;',
'  l_message_item  VARCHAR2(100) := p_dynamic_action.attribute_05;',
'  l_optparam_item VARCHAR2(100) := p_dynamic_action.attribute_06;',
'  l_wait_spinner  VARCHAR2(50) := p_dynamic_action.attribute_07;',
'  l_logging       VARCHAR2(50) := p_dynamic_action.attribute_08;',
'  l_source        VARCHAR2(100) := p_dynamic_action.attribute_09;',
'  --',
'BEGIN',
'  -- attribute defaults',
'  l_wait_spinner := nvl(l_wait_spinner,',
'                        ''true'');',
'  l_logging      := nvl(l_logging,',
'                        ''false'');',
'  -- Debug',
'  IF apex_application.g_debug THEN',
'    apex_plugin_util.debug_dynamic_action(p_plugin         => p_plugin,',
'                                          p_dynamic_action => p_dynamic_action);',
'  END IF;',
'  --',
'  --',
'  l_result.javascript_function := ''sendNotifyWebsocket.sendNotify'';',
'  l_result.ajax_identifier     := apex_plugin.get_ajax_identifier;',
'  l_result.attribute_01        := l_userid_item;',
'  l_result.attribute_02        := l_ws_room_item;',
'  l_result.attribute_03        := l_ws_type_item;',
'  l_result.attribute_04        := l_title_item;',
'  l_result.attribute_05        := l_message_item;',
'  l_result.attribute_06        := l_optparam_item;',
'  l_result.attribute_07        := l_wait_spinner;',
'  l_result.attribute_08        := l_logging;',
'  l_result.attribute_09        := l_source;',
'  --',
'  RETURN l_result;',
'  --',
'END render_send_ws_notify;',
'--',
'--',
'-- AJAX function',
'--',
'--',
'FUNCTION ajax_send_ws_notify(p_dynamic_action IN apex_plugin.t_dynamic_action,',
'                             p_plugin         IN apex_plugin.t_plugin)',
'  RETURN apex_plugin.t_dynamic_action_ajax_result IS',
'  --',
'  -- plugin attributes',
'  l_result      apex_plugin.t_dynamic_action_ajax_result;',
'  l_source      VARCHAR2(100) := p_dynamic_action.attribute_09;',
'  l_sql_query   p_dynamic_action.attribute_10%TYPE := p_dynamic_action.attribute_10;',
'  l_escape_html VARCHAR2(50) := p_dynamic_action.attribute_11;',
'  -- other vars',
'  l_userid    VARCHAR2(4000);',
'  l_room      VARCHAR2(4000);',
'  l_type      VARCHAR2(4000);',
'  l_title     VARCHAR2(4000);',
'  l_message   VARCHAR2(4000);',
'  l_opt_param VARCHAR2(4000);',
'  -- vars for sql query parse',
'  l_data_type_list    apex_application_global.vc_arr2;',
'  l_column_value_list apex_plugin_util.t_column_value_list2;',
'  --',
'BEGIN',
'  -- check notification source',
'  -- Info from Item',
'  IF l_source = ''ITEM'' THEN',
'    l_userid    := apex_application.g_x01;',
'    l_room      := apex_application.g_x02;',
'    l_type      := apex_application.g_x03;',
'    l_title     := apex_application.g_x04;',
'    l_message   := apex_application.g_x05;',
'    l_opt_param := apex_application.g_x06;',
'    -- Info from SQL Query',
'  ELSIF l_source = ''SQL'' THEN',
'    -- Data Types of SQL Source Columns',
'    l_data_type_list(1) := apex_plugin_util.c_data_type_varchar2;',
'    l_data_type_list(2) := apex_plugin_util.c_data_type_varchar2;',
'    l_data_type_list(3) := apex_plugin_util.c_data_type_varchar2;',
'    l_data_type_list(4) := apex_plugin_util.c_data_type_varchar2;',
'    l_data_type_list(5) := apex_plugin_util.c_data_type_varchar2;',
'    l_data_type_list(6) := apex_plugin_util.c_data_type_varchar2;',
'    -- Get Data from SQL Source',
'    l_column_value_list := apex_plugin_util.get_data2(p_sql_statement  => l_sql_query,',
'                                                      p_min_columns    => 6,',
'                                                      p_max_columns    => 6,',
'                                                      p_component_name => p_dynamic_action.action);',
'    -- fetch data from first row',
'    l_userid    := l_column_value_list(1).value_list(1).varchar2_value;',
'    l_room      := l_column_value_list(2).value_list(1).varchar2_value;',
'    l_type      := l_column_value_list(3).value_list(1).varchar2_value;',
'    l_title     := l_column_value_list(4).value_list(1).varchar2_value;',
'    l_message   := l_column_value_list(5).value_list(1).varchar2_value;',
'    l_opt_param := l_column_value_list(6).value_list(1).varchar2_value;',
'  END IF;',
'  -- escape html',
'  IF l_escape_html = ''true'' THEN',
'    l_userid    := apex_escape.html(l_userid);',
'    l_room      := apex_escape.html(l_room);',
'    l_type      := apex_escape.html(l_type);',
'    l_title     := apex_escape.html(l_title);',
'    l_message   := apex_escape.html(l_message);',
'    l_opt_param := apex_escape.html(l_opt_param);',
'  END IF;',
'  --',
'  -- call send procedure',
'  ws_notify_api.do_rest_notify_user(i_userid   => l_userid,',
'                                    i_room     => l_room,',
'                                    i_type     => l_type,',
'                                    i_title    => l_title,',
'                                    i_message  => l_message,',
'                                    i_optparam => l_opt_param);',
'  --',
'  RETURN l_result;',
'  --',
'END ajax_send_ws_notify;'))
,p_render_function=>'render_send_ws_notify'
,p_ajax_function=>'ajax_send_ws_notify'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'Send websocket notifications to users'
,p_version_identifier=>'1.2'
,p_about_url=>'https://github.com/Dani3lSun/apex-websocket-notify-bundle'
,p_files_version=>461
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19829465543532595)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'To User (User-ID)'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(16381583556456375)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'ITEM'
,p_help_text=>'Item which holds informations about the User-ID or Username of the user who get´s the notification'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19829842132547386)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Websocket Room'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(16381583556456375)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'ITEM'
,p_examples=>'Valid values: "private" or "public"'
,p_help_text=>'Item which holds informations about the websocket room'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19830756370560180)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Notification Type'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(16381583556456375)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'ITEM'
,p_examples=>'Valid values: info, success, warn, error'
,p_help_text=>'Item which holds informations about the type of the notification'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19830989032564418)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Notification Title'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(16381583556456375)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'ITEM'
,p_help_text=>'Item which holds informations about the title of the notification'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19831270810568292)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Notification Message'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(16381583556456375)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'ITEM'
,p_help_text=>'Item which holds informations about the message content of the notification'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19831592997579618)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Optional Parameter'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(16381583556456375)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'ITEM'
,p_examples=>'This could be any kind of string or number combination. This information can be processed on the client side'
,p_help_text=>'Item which holds informations about a optional parameter'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19833559490718137)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Show Wait Spinner'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'true'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Show / Hide wait spinner for AJAX call'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19833868238718675)
,p_plugin_attribute_id=>wwv_flow_api.id(19833559490718137)
,p_display_sequence=>10
,p_display_value=>'True'
,p_return_value=>'true'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19834299258719129)
,p_plugin_attribute_id=>wwv_flow_api.id(19833559490718137)
,p_display_sequence=>20
,p_display_value=>'False'
,p_return_value=>'false'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19819590089510885)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Logging'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'false'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Whether to log events in the console.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19820000904510885)
,p_plugin_attribute_id=>wwv_flow_api.id(19819590089510885)
,p_display_sequence=>10
,p_display_value=>'True'
,p_return_value=>'true'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19820508974510885)
,p_plugin_attribute_id=>wwv_flow_api.id(19819590089510885)
,p_display_sequence=>20
,p_display_value=>'False'
,p_return_value=>'false'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(16381583556456375)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>1
,p_prompt=>'Source'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'ITEM'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Source of all Notification relevant informations.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(16382222439456977)
,p_plugin_attribute_id=>wwv_flow_api.id(16381583556456375)
,p_display_sequence=>10
,p_display_value=>'Items'
,p_return_value=>'ITEM'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(16382608457457518)
,p_plugin_attribute_id=>wwv_flow_api.id(16381583556456375)
,p_display_sequence=>20
,p_display_value=>'SQL Query'
,p_return_value=>'SQL'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(16387837153474994)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>65
,p_prompt=>'SQL Query'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_sql_min_column_count=>6
,p_sql_max_column_count=>6
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(16381583556456375)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'SQL'
,p_examples=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'<pre>',
'SELECT :app_user AS user_id,',
'       ''private'' AS room, -- private, public',
'       ''info'' AS notify_type, -- info, success, warn, error',
'       ''Test Title'' AS title,',
'       ''My Test Message Content...'' AS message,',
'       ''123:abc'' AS optional_parameter',
'  FROM dual',
'</pre>'))
,p_help_text=>'SQL Query which returns all relevant informations for sending a notification. The Query should only return one row!'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(16398096757625538)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>75
,p_prompt=>'Escape HTML'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'true'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Whether to escape special chars (HTML) or not.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(16399181634625971)
,p_plugin_attribute_id=>wwv_flow_api.id(16398096757625538)
,p_display_sequence=>10
,p_display_value=>'True'
,p_return_value=>'true'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(16399513731626399)
,p_plugin_attribute_id=>wwv_flow_api.id(16398096757625538)
,p_display_sequence=>20
,p_display_value=>'False'
,p_return_value=>'false'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(19822202826510888)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_name=>'ws-send-notify-error'
,p_display_name=>'Send Notification error'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(19836094115809111)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_name=>'ws-send-notify-missing-values'
,p_display_name=>'Send Notification missing values'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(19821821351510888)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_name=>'ws-send-notify-success'
,p_display_name=>'Send Notification success'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2F2053656E6420576562736F636B6574204E6F746966790A2F2F20417574686F723A2044616E69656C20486F63686C6569746E65720A2F2F2056657273696F6E3A20312E320A0A2F2F20676C6F62616C206E616D6573706163650A7661722073656E64';
wwv_flow_api.g_varchar2_table(2) := '4E6F74696679576562736F636B6574203D207B0A20202F2F20706172736520737472696E6720746F20626F6F6C65616E0A20207061727365426F6F6C65616E3A2066756E6374696F6E2870537472696E6729207B0A202020207661722070426F6F6C6561';
wwv_flow_api.g_varchar2_table(3) := '6E3B0A202020206966202870537472696E672E746F4C6F776572436173652829203D3D2027747275652729207B0A20202020202070426F6F6C65616E203D20747275653B0A202020207D0A202020206966202870537472696E672E746F4C6F7765724361';
wwv_flow_api.g_varchar2_table(4) := '73652829203D3D202766616C73652729207B0A20202020202070426F6F6C65616E203D2066616C73653B0A202020207D0A2020202069662028212870537472696E672E746F4C6F776572436173652829203D3D2027747275652729202626202128705374';
wwv_flow_api.g_varchar2_table(5) := '72696E672E746F4C6F776572436173652829203D3D202766616C7365272929207B0A20202020202070426F6F6C65616E203D20756E646566696E65643B0A202020207D0A2020202072657475726E2070426F6F6C65616E3B0A20207D2C0A20202F2F2066';
wwv_flow_api.g_varchar2_table(6) := '756E6374696F6E207468617420676574732063616C6C65642066726F6D20706C7567696E0A202073656E644E6F746966793A2066756E6374696F6E2829207B0A202020202F2F20706C7567696E20617474726962757465730A2020202076617220646154';
wwv_flow_api.g_varchar2_table(7) := '686973203D20746869733B0A202020207661722076416A61784964656E746966696572203D206461546869732E616374696F6E2E616A61784964656E7469666965723B0A2020202076617220765573657249644974656D203D206461546869732E616374';
wwv_flow_api.g_varchar2_table(8) := '696F6E2E61747472696275746530313B0A202020207661722076526F6F6D4974656D203D206461546869732E616374696F6E2E61747472696275746530323B0A202020207661722076547970654974656D203D206461546869732E616374696F6E2E6174';
wwv_flow_api.g_varchar2_table(9) := '7472696275746530333B0A2020202076617220765469746C654974656D203D206461546869732E616374696F6E2E61747472696275746530343B0A2020202076617220764D6573736167654974656D203D206461546869732E616374696F6E2E61747472';
wwv_flow_api.g_varchar2_table(10) := '696275746530353B0A2020202076617220764F7074506172616D4974656D203D206461546869732E616374696F6E2E61747472696275746530363B0A20202020766172207653686F77576169745370696E6E6572203D2073656E644E6F74696679576562';
wwv_flow_api.g_varchar2_table(11) := '736F636B65742E7061727365426F6F6C65616E286461546869732E616374696F6E2E6174747269627574653037293B0A2020202076617220764C6F6767696E67203D2073656E644E6F74696679576562736F636B65742E7061727365426F6F6C65616E28';
wwv_flow_api.g_varchar2_table(12) := '6461546869732E616374696F6E2E6174747269627574653038293B0A202020207661722076536F75726365203D206461546869732E616374696F6E2E61747472696275746530393B0A2020202076617220765573657249643B0A20202020766172207652';
wwv_flow_api.g_varchar2_table(13) := '6F6F6D3B0A202020207661722076547970653B0A2020202076617220765469746C653B0A2020202076617220764D6573736167653B0A2020202076617220764F7074506172616D3B0A202020202F2F206974656D2076616C7565730A2020202069662028';
wwv_flow_api.g_varchar2_table(14) := '76536F75726365203D3D20274954454D2729207B0A20202020202076557365724964203D20247628765573657249644974656D293B0A20202020202076526F6F6D203D2024762876526F6F6D4974656D293B0A2020202020207654797065203D20247628';
wwv_flow_api.g_varchar2_table(15) := '76547970654974656D293B0A202020202020765469746C65203D20247628765469746C654974656D293B0A202020202020764D657373616765203D20247628764D6573736167654974656D293B0A202020202020764F7074506172616D203D2024762876';
wwv_flow_api.g_varchar2_table(16) := '4F7074506172616D4974656D293B0A202020207D0A202020202F2F204C6F6767696E670A2020202069662028764C6F6767696E6729207B0A202020202020636F6E736F6C652E6C6F67282773656E644E6F746966793A20506C7567696E20416A61784964';
wwv_flow_api.g_varchar2_table(17) := '656E7469666965723A272C2076416A61784964656E746966696572293B0A202020202020636F6E736F6C652E6C6F67282773656E644E6F746966793A20536F757263653A272C2076536F75726365293B0A202020202020636F6E736F6C652E6C6F672827';
wwv_flow_api.g_varchar2_table(18) := '73656E644E6F746966793A2041747472696275746520557365722D4944204974656D3A272C20765573657249644974656D293B0A202020202020636F6E736F6C652E6C6F67282773656E644E6F746966793A2041747472696275746520576562736F636B';
wwv_flow_api.g_varchar2_table(19) := '657420526F6F6D204974656D3A272C2076526F6F6D4974656D293B0A202020202020636F6E736F6C652E6C6F67282773656E644E6F746966793A20417474726962757465204E6F74696669636174696F6E2054797065204974656D3A272C207654797065';
wwv_flow_api.g_varchar2_table(20) := '4974656D293B0A202020202020636F6E736F6C652E6C6F67282773656E644E6F746966793A20417474726962757465204E6F74696669636174696F6E205469746C65204974656D3A272C20765469746C654974656D293B0A202020202020636F6E736F6C';
wwv_flow_api.g_varchar2_table(21) := '652E6C6F67282773656E644E6F746966793A20417474726962757465204E6F74696669636174696F6E204D657373616765204974656D3A272C20764D6573736167654974656D293B0A202020202020636F6E736F6C652E6C6F67282773656E644E6F7469';
wwv_flow_api.g_varchar2_table(22) := '66793A20417474726962757465204F7074696F6E616C20506172616D65746572204974656D3A272C20764F7074506172616D4974656D293B0A202020202020636F6E736F6C652E6C6F67282773656E644E6F746966793A20417474726962757465205573';
wwv_flow_api.g_varchar2_table(23) := '65722D4944204974656D3A272C2076557365724964293B0A202020202020636F6E736F6C652E6C6F67282773656E644E6F746966793A2041747472696275746520576562736F636B657420526F6F6D2056616C75653A272C2076526F6F6D293B0A202020';
wwv_flow_api.g_varchar2_table(24) := '202020636F6E736F6C652E6C6F67282773656E644E6F746966793A20417474726962757465204E6F74696669636174696F6E20547970652056616C75653A272C207654797065293B0A202020202020636F6E736F6C652E6C6F67282773656E644E6F7469';
wwv_flow_api.g_varchar2_table(25) := '66793A20417474726962757465204E6F74696669636174696F6E205469746C652056616C75653A272C20765469746C65293B0A202020202020636F6E736F6C652E6C6F67282773656E644E6F746966793A20417474726962757465204E6F746966696361';
wwv_flow_api.g_varchar2_table(26) := '74696F6E204D6573736167652056616C75653A272C20764D657373616765293B0A202020202020636F6E736F6C652E6C6F67282773656E644E6F746966793A20417474726962757465204F7074696F6E616C20506172616D657465722056616C75653A27';
wwv_flow_api.g_varchar2_table(27) := '2C20764F7074506172616D293B0A202020202020636F6E736F6C652E6C6F67282773656E644E6F746966793A204174747269627574652053686F772057616974205370696E6E65723A272C207653686F77576169745370696E6E6572293B0A2020202020';
wwv_flow_api.g_varchar2_table(28) := '20636F6E736F6C652E6C6F67282773656E644E6F746966793A20417474726962757465204C6F6767696E673A272C20764C6F6767696E67293B0A202020207D0A202020202F2F20414A41582063616C6C2073656E64204E6F74696669636174696F6E0A20';
wwv_flow_api.g_varchar2_table(29) := '2020202F2F20636865636B20706172616D657465722076616C7565730A202020206966202828765573657249642026262076526F6F6D20262620765479706520262620765469746C6520262620764D65737361676529207C7C2076536F75726365203D3D';
wwv_flow_api.g_varchar2_table(30) := '202753514C2729207B0A2020202020202F2F2073686F77207370696E6E65720A202020202020696620287653686F77576169745370696E6E657229207B0A2020202020202020766172206C5370696E6E657224203D20617065782E7574696C2E73686F77';
wwv_flow_api.g_varchar2_table(31) := '5370696E6E65722827626F647927293B0A2020202020207D0A2020202020202F2F206368616E67652064656661756C747320696620616C6C2075736572730A202020202020766172206C526F6F6D3B0A2020202020206966202876557365724964203D3D';
wwv_flow_api.g_varchar2_table(32) := '3D2027616C6C2729207B0A20202020202020206C526F6F6D203D20277075626C6963273B0A2020202020207D20656C7365207B0A20202020202020206C526F6F6D203D2076526F6F6D3B0A2020202020207D0A20202020202024732876526F6F6D497465';
wwv_flow_api.g_varchar2_table(33) := '6D2C206C526F6F6D293B0A2020202020202F2F206173796E63207365727665722063616C6C0A202020202020617065782E7365727665722E706C7567696E2876416A61784964656E7469666965722C207B0A20202020202020207830313A207655736572';
wwv_flow_api.g_varchar2_table(34) := '49642C0A20202020202020207830323A206C526F6F6D2C0A20202020202020207830333A2076547970652C0A20202020202020207830343A20765469746C652C0A20202020202020207830353A20764D6573736167652C0A20202020202020207830363A';
wwv_flow_api.g_varchar2_table(35) := '20764F7074506172616D0A2020202020207D2C207B0A202020202020202064617461547970653A202768746D6C272C0A20202020202020202F2F205355434553532066756E6374696F6E0A2020202020202020737563636573733A2066756E6374696F6E';
wwv_flow_api.g_varchar2_table(36) := '2829207B0A202020202020202020202F2F206164642061706578206576656E740A20202020202020202020617065782E6576656E742E747269676765722827626F6479272C202777732D73656E642D6E6F746966792D7375636365737327293B0A202020';
wwv_flow_api.g_varchar2_table(37) := '202020202020202F2F2068696465207370696E6E65720A20202020202020202020696620287653686F77576169745370696E6E657229207B0A2020202020202020202020206C5370696E6E6572242E72656D6F766528293B0A202020202020202020207D';
wwv_flow_api.g_varchar2_table(38) := '0A20202020202020207D2C0A20202020202020202F2F204552524F522066756E6374696F6E0A20202020202020206572726F723A2066756E6374696F6E287868722C20704D65737361676529207B0A202020202020202020202F2F206164642061706578';
wwv_flow_api.g_varchar2_table(39) := '206576656E740A20202020202020202020617065782E6576656E742E747269676765722827626F6479272C202777732D73656E642D6E6F746966792D6572726F7227293B0A202020202020202020202F2F2068696465207370696E6E65720A2020202020';
wwv_flow_api.g_varchar2_table(40) := '2020202020696620287653686F77576169745370696E6E657229207B0A2020202020202020202020206C5370696E6E6572242E72656D6F766528293B0A202020202020202020207D0A20202020202020207D0A2020202020207D293B0A202020207D2065';
wwv_flow_api.g_varchar2_table(41) := '6C7365207B0A2020202020202F2F206164642061706578206576656E740A202020202020617065782E6576656E742E747269676765722827626F6479272C202777732D73656E642D6E6F746966792D6D697373696E672D76616C75657327293B0A202020';
wwv_flow_api.g_varchar2_table(42) := '207D0A20207D0A7D3B0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(19834907643800190)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_file_name=>'sendNotifyWebsocket.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7661722073656E644E6F74696679576562736F636B65743D7B7061727365426F6F6C65616E3A66756E6374696F6E2862297B76617220613B2274727565223D3D622E746F4C6F776572436173652829262628613D2130293B2266616C7365223D3D622E74';
wwv_flow_api.g_varchar2_table(2) := '6F4C6F776572436173652829262628613D2131293B227472756522213D622E746F4C6F77657243617365282926262266616C736522213D622E746F4C6F776572436173652829262628613D766F69642030293B72657475726E20617D2C73656E644E6F74';
wwv_flow_api.g_varchar2_table(3) := '6966793A66756E6374696F6E28297B76617220623D746869732E616374696F6E2E616A61784964656E7469666965722C613D746869732E616374696F6E2E61747472696275746530312C6B3D746869732E616374696F6E2E61747472696275746530322C';
wwv_flow_api.g_varchar2_table(4) := '6E3D746869732E616374696F6E2E61747472696275746530332C703D746869732E616374696F6E2E61747472696275746530342C713D746869732E616374696F6E2E61747472696275746530352C723D746869732E616374696F6E2E6174747269627574';
wwv_flow_api.g_varchar2_table(5) := '6530362C643D73656E644E6F74696679576562736F636B65742E7061727365426F6F6C65616E28746869732E616374696F6E2E6174747269627574653037292C743D73656E644E6F74696679576562736F636B65742E7061727365426F6F6C65616E2874';
wwv_flow_api.g_varchar2_table(6) := '6869732E616374696F6E2E6174747269627574653038292C0A6C3D746869732E616374696F6E2E61747472696275746530392C632C652C662C672C682C6D3B224954454D223D3D6C262628633D24762861292C653D2476286B292C663D2476286E292C67';
wwv_flow_api.g_varchar2_table(7) := '3D24762870292C683D24762871292C6D3D2476287229293B74262628636F6E736F6C652E6C6F67282273656E644E6F746966793A20506C7567696E20416A61784964656E7469666965723A222C62292C636F6E736F6C652E6C6F67282273656E644E6F74';
wwv_flow_api.g_varchar2_table(8) := '6966793A20536F757263653A222C6C292C636F6E736F6C652E6C6F67282273656E644E6F746966793A2041747472696275746520557365722D4944204974656D3A222C61292C636F6E736F6C652E6C6F67282273656E644E6F746966793A204174747269';
wwv_flow_api.g_varchar2_table(9) := '6275746520576562736F636B657420526F6F6D204974656D3A222C6B292C636F6E736F6C652E6C6F67282273656E644E6F746966793A20417474726962757465204E6F74696669636174696F6E2054797065204974656D3A222C6E292C636F6E736F6C65';
wwv_flow_api.g_varchar2_table(10) := '2E6C6F67282273656E644E6F746966793A20417474726962757465204E6F74696669636174696F6E205469746C65204974656D3A222C70292C636F6E736F6C652E6C6F67282273656E644E6F746966793A20417474726962757465204E6F746966696361';
wwv_flow_api.g_varchar2_table(11) := '74696F6E204D657373616765204974656D3A222C71292C636F6E736F6C652E6C6F67282273656E644E6F746966793A20417474726962757465204F7074696F6E616C20506172616D65746572204974656D3A222C0A72292C636F6E736F6C652E6C6F6728';
wwv_flow_api.g_varchar2_table(12) := '2273656E644E6F746966793A2041747472696275746520557365722D4944204974656D3A222C63292C636F6E736F6C652E6C6F67282273656E644E6F746966793A2041747472696275746520576562736F636B657420526F6F6D2056616C75653A222C65';
wwv_flow_api.g_varchar2_table(13) := '292C636F6E736F6C652E6C6F67282273656E644E6F746966793A20417474726962757465204E6F74696669636174696F6E20547970652056616C75653A222C66292C636F6E736F6C652E6C6F67282273656E644E6F746966793A20417474726962757465';
wwv_flow_api.g_varchar2_table(14) := '204E6F74696669636174696F6E205469746C652056616C75653A222C67292C636F6E736F6C652E6C6F67282273656E644E6F746966793A20417474726962757465204E6F74696669636174696F6E204D6573736167652056616C75653A222C68292C636F';
wwv_flow_api.g_varchar2_table(15) := '6E736F6C652E6C6F67282273656E644E6F746966793A20417474726962757465204F7074696F6E616C20506172616D657465722056616C75653A222C6D292C636F6E736F6C652E6C6F67282273656E644E6F746966793A20417474726962757465205368';
wwv_flow_api.g_varchar2_table(16) := '6F772057616974205370696E6E65723A222C64292C636F6E736F6C652E6C6F67282273656E644E6F746966793A20417474726962757465204C6F6767696E673A222C7429293B696628632626652626662626672626687C7C0A2253514C223D3D6C297B69';
wwv_flow_api.g_varchar2_table(17) := '6628642976617220753D617065782E7574696C2E73686F775370696E6E65722822626F647922293B613D22616C6C223D3D3D633F227075626C6963223A653B2473286B2C61293B617065782E7365727665722E706C7567696E28622C7B7830313A632C78';
wwv_flow_api.g_varchar2_table(18) := '30323A612C7830333A662C7830343A672C7830353A682C7830363A6D7D2C7B64617461547970653A2268746D6C222C737563636573733A66756E6374696F6E28297B617065782E6576656E742E747269676765722822626F6479222C2277732D73656E64';
wwv_flow_api.g_varchar2_table(19) := '2D6E6F746966792D7375636365737322293B642626752E72656D6F766528297D2C6572726F723A66756E6374696F6E28612C62297B617065782E6576656E742E747269676765722822626F6479222C2277732D73656E642D6E6F746966792D6572726F72';
wwv_flow_api.g_varchar2_table(20) := '22293B642626752E72656D6F766528297D7D297D656C736520617065782E6576656E742E747269676765722822626F6479222C2277732D73656E642D6E6F746966792D6D697373696E672D76616C75657322297D7D3B0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(19835339575801177)
,p_plugin_id=>wwv_flow_api.id(19816233540510881)
,p_file_name=>'sendNotifyWebsocket.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
