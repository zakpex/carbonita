prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run the script connected to SQL*Plus as the owner (parsing schema)
-- of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2022.10.07'
,p_release=>'22.2.0'
,p_default_workspace_id=>3001170721051328
,p_default_application_id=>203
,p_default_id_offset=>0
,p_default_owner=>'DEV'
);
end;
/
 
prompt APPLICATION 203 - carbonita
--
-- Application Export:
--   Application:     203
--   Name:            carbonita
--   Date and Time:   13:42 Wednesday December 14, 2022
--   Exported By:     ZAKI
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 48745522732537372
--   Manifest End
--   Version:         22.2.0
--   Instance ID:     800172743070494
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/com_ceramig_carbonita
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(48745522732537372)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'COM.CERAMIG.CARBONITA'
,p_display_name=>'carbonita.da'
,p_category=>'EXECUTE'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#PLUGIN_FILES#carbonita#MIN#.js',
'#PLUGIN_FILES#FileSaver#MIN#.js'))
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'    const_nodejs_url  constant VARCHAR2(250)  :=  ''http://10.1.1.142:8000/'';',
'    const_req_newline CONSTANT VARCHAR2(50) := chr(13)',
'                                           || chr(10);',
'    const_req_boundary CONSTANT VARCHAR2(50) := ''----FormBoundary7MA4YWxkTrZu0gW'';',
'    const_req_encoding CONSTANT VARCHAR2(250) := ''base64'';',
'    const_v_newline CONSTANT VARCHAR2(10) := chr(13)',
'                                             || chr(10);',
'    const_v_boundary CONSTANT VARCHAR2(60) := ''---------------------------30837156019033'';',
'    const_v_end CONSTANT VARCHAR2(10) := ''--'';',
'    const_v_separator CONSTANT VARCHAR2(10) := '';'';',
'      procedure message_error(l_data_clob IN CLOB default null, l_sqlerrm in varchar2 default null) is',
'    begin',
'        apex_json.open_object;',
'                        apex_json.write(''status'', ''error'');',
'                        apex_json.write(''message'', l_sqlerrm);',
'                        apex_json.write(''message'', l_data_clob);',
'                        apex_json.close_object;',
'',
'    end message_error;   ',
'      FUNCTION carbonita_priv_build_req_body (',
'                req_template_blob     IN BLOB,',
'                req_template_mimetype IN VARCHAR2 DEFAULT ''application/vnd.openxmlformats-officedocument.wordprocessingml.document'',',
'                req_data        IN CLOB,',
'                         --   req_data_charset   in  varchar2 ,  -- ISO-8859-1 to  WE8ISO8859P1     ',
'                req_reporttype        IN VARCHAR2,',
'                req_encoding          IN VARCHAR2, -- template encoding binary or clobbase64',
'                req_reportname        IN VARCHAR2',
'        ) RETURN CLOB AS',
'',
'            l_req_charset     VARCHAR2(250);',
'            l_db_charset     VARCHAR2(250);',
'            l_req_body_return CLOB;',
'            l_data_clob       CLOB;',
'            l_str_part        VARCHAR2(32767);',
'            l_length          INTEGER;',
'            l_start           INTEGER := 1;',
'            l_recsize         CONSTANT INTEGER := 4000;',
'        BEGIN',
'        -- TODO optimze pretify ',
'            utl_http.get_body_charset(charset => l_req_charset); --WE8ISO8859P1: ISO 8859-1',
'            select property_value into l_db_charset from database_properties where property_name = ''NLS_CHARACTERSET'';',
'',
'',
'            dbms_lob.createtemporary(l_data_clob, false);',
'            IF 1 = 1 THEN',
'                BEGIN -- convert report_date ',
'                 -- Convert  data( from the query ) from charset AL32UTF8 (db charset) to WE8ISO8859P1 (utl http charset)',
'                 -- ... we convert by parts to avoid 32K limit ',
'                 -- ... initialy was l_data_clob :=convert( dbms_lob.substr(req_data,dbms_lob.getlength(req_data)),''AL32UTF8'', ''WE8ISO8859P1''); -- size problem',
'',
'                    l_length := dbms_lob.getlength(req_data);',
'                    dbms_lob.createtemporary(l_data_clob, false);',
'                    WHILE l_start <= l_length LOOP',
'                        l_str_part := dbms_lob.substr(req_data, l_recsize, l_start);',
'                        if l_req_charset = ''ISO-8859-1'' then ',
'                            dbms_lob.append(l_data_clob, convert(l_str_part, ''AL32UTF8'', ''WE8ISO8859P1''));',
'                        else',
'                            dbms_lob.append(l_data_clob, l_str_part );',
'                        end if;',
'                        --dbms_lob.append(l_data_clob, convert(l_str_part, l_db_charset,l_req_charset)); -- fail ?',
'',
'                        l_start := l_start + l_recsize;',
'                    END LOOP;',
'',
'                END;',
'            END IF;',
'',
'            dbms_lob.createtemporary(l_req_body_return, false); -- how useful ?',
'            l_req_body_return := const_req_newline',
'                                 || ''--''',
'                                 || const_req_boundary',
'                                 || const_req_newline',
'                                 || ''Content-Disposition: form-data; name="template_binary"; filename="template_binary"''',
'                                 || const_req_newline',
'                                 || ''Content-Type: ''',
'                                 || req_template_mimetype-- ''application/any.recognized.libreoffice''',
'                                 || const_req_newline',
'                                 || const_req_newline',
'                                 || apex_web_service.blob2clobbase64(req_template_blob)',
'                                 || const_req_newline',
'                                 || ''--''',
'                                 || const_req_boundary',
'                                 || const_req_newline',
'                      /*',
'                      || ''Content-Disposition: form-data; name="filename"''',
'                      || const_req_newline',
'                      || const_req_newline',
'                      || ''filetemplate.docx''',
'                      || const_req_newline || ''--'' || const_req_boundary || const_req_newline',
'',
'                      || ''Content-Disposition: form-data; name="MAX_FILE_SIZE"''',
'                      || const_req_newline',
'                      || const_req_newline',
'                      || ''4000000''',
'                      || const_req_newline || ''--'' || const_req_boundary || const_req_newline',
'                      */',
'                                 || ''Content-Disposition: form-data; name="report_type"''',
'                                 || const_req_newline',
'                                 || const_req_newline',
'                                 || req_reporttype',
'                                 || const_req_newline',
'                                 || ''--''',
'                                 || const_req_boundary',
'                                 || const_req_newline',
'                                 || ''Content-Disposition: form-data; name="req_encoding"''',
'                                 || const_req_newline',
'                                 || const_req_newline',
'                                 || req_encoding',
'                                 || const_req_newline',
'                                 || ''--''',
'                                 || const_req_boundary',
'                                 || const_req_newline',
'                                 || ''Content-Disposition: form-data; name="report_name"''',
'                                 || const_req_newline',
'                                 || const_req_newline',
'                                 || req_reportname',
'                                 || const_req_newline',
'                                 || ''--''',
'                                 || const_req_boundary',
'                                 || const_req_newline',
'                                 || ''Content-Disposition: form-data; name="data_text"''',
'                                 || const_req_newline',
'                                 || const_req_newline',
'                                 ||',
'                CASE',
'                    WHEN 1 = 1 OR l_req_charset = ''ISO 8859-1'' -- is the case by default',
'                     THEN',
'                        l_data_clob',
'                                --req_data',
'                            --convert(',
'                              --  req_data,',
'                                --dbms_lob.substr(req_data, dbms_lob.getlength(req_data)), ',
'                                    --''AL32UTF8'', ''WE8ISO8859P1'')',
'                    ELSE l_data_clob -- req_data',
'                END',
'                                 || const_req_newline',
'                                 || ''--''',
'                                 || const_req_boundary',
'                                 || ''--'';',
'',
'            dbms_lob.freetemporary(l_data_clob);',
'            RETURN l_req_body_return;',
'        END carbonita_priv_build_req_body;',
'     PROCEDURE carbonita_priv_post_req (',
'            req_body     IN out CLOB,',
'            req_url        IN VARCHAR2 ,',
'            out_blob     OUT BLOB,',
'            out_mimetype OUT VARCHAR2,',
'            out_filename OUT VARCHAR2,',
'            out_size     OUT NUMBER --?? ',
'        ) AS',
'',
'            l_request_body_length   NUMBER;',
'            l_http_request          utl_http.req;',
'            l_http_response         utl_http.resp;',
'            l_response_header_name  VARCHAR2(256);',
'            l_response_header_value VARCHAR2(2000);',
'',
'                 --l_response_blob blob; -- output ',
'            l_offset                NUMBER := 1;',
'            l_amount                NUMBER := 2000;',
'            l_buffer                VARCHAR2(4000);',
'            l_raw                   RAW(32767);',
'',
'        BEGIN',
'            l_request_body_length := dbms_lob.getlength(req_body);',
'            utl_http.set_transfer_timeout(200);',
'            l_http_request := utl_http.begin_request(url => req_url, method => ''POST'', http_version => ''HTTP/1.1'');',
'',
'            utl_http.set_header(l_http_request, ''Content-Type'', ''multipart/form-data; boundary="''',
'                                                                || const_req_boundary',
'                                                                || ''"'');',
'            utl_http.set_header(l_http_request, ''Content-Length'', l_request_body_length);',
'            WHILE l_offset < l_request_body_length LOOP',
'                dbms_lob.read(req_body, l_amount, l_offset, l_buffer);',
'                utl_http.write_text(l_http_request, l_buffer);',
'                l_offset := l_offset + l_amount;',
'            END LOOP;',
'',
'            l_http_response := utl_http.get_response(l_http_request);',
'            BEGIN',
'                FOR i IN 1..utl_http.get_header_count(l_http_response) LOOP',
'                    utl_http.get_header(l_http_response, i, l_response_header_name, l_response_header_value);',
'                    IF l_response_header_name = ''Content-Disposition'' THEN',
'                        out_filename := regexp_substr(l_response_header_value, ''(filename=)([^,]+)'', 1, 1, ''i'',',
'                                                     2);',
'                    END IF;',
'',
'                    IF l_response_header_name = ''Content-Type'' THEN',
'                        out_mimetype := l_response_header_value;',
'                    END IF;',
'                    IF l_response_header_name = ''Content-Length'' THEN',
'                        out_size := l_response_header_value;',
'                    END IF;',
'                END LOOP;',
'',
'                dbms_lob.createtemporary(out_blob, false);--utl_http.read_text(l_http_response, l_response_body, 32767);',
'',
'                BEGIN',
'                    LOOP',
'                        utl_http.read_raw(l_http_response, l_raw, 32766);',
'                        dbms_lob.writeappend(out_blob, utl_raw.length(l_raw), l_raw);',
'                    END LOOP;',
'                EXCEPTION',
'                    WHEN utl_http.end_of_body THEN utl_http.end_response(l_http_response);',
'',
'',
'                    when others then       dbms_lob.freetemporary(out_blob); ',
'                END;',
'',
'',
'',
'            EXCEPTION',
'                                --WHEN UTL_HTTP.end_of_body THEN',
'                                --       UTL_HTTP.end_response(l_http_response);',
'                                --       UTL_HTTP.end_request(l_http_request);',
'                WHEN OTHERS THEN',
'                    IF l_http_request.private_hndl IS NOT NULL THEN',
'                        utl_http.end_request(l_http_request);',
'                        dbms_lob.freetemporary(out_blob); ',
'                        dbms_lob.freetemporary(req_body); ',
'                    END IF;',
'                    IF l_http_response.private_hndl IS NOT NULL THEN',
'                        utl_http.end_response(l_http_response);',
'                        dbms_lob.freetemporary(out_blob); ',
'                        dbms_lob.freetemporary(req_body); ',
'                    END IF;',
'                    RAISE;',
'            END;',
'',
'        END carbonita_priv_post_req;',
'   procedure carbonita_pkg_get_report_template(',
'        p_template_static   in varchar2,',
'        p_app_id            in number DEFAULT v(''APP_ID''), ',
'',
'        out_template_blob     out blob,',
'        out_template_mimetype out varchar2',
'                            ) as ',
'    begin',
'    -- TODO: MIME_TYPE  FILE_CHARSET  ',
'        begin',
'            SELECT  blob_content,  ',
'                    mime_type',
'                INTO out_template_blob, ',
'                     out_template_mimetype',
'        FROM apex_application_files',
'        WHERE   file_type = ''STATIC_FILE''',
'            AND flow_id = p_app_id',
'            AND filename = p_template_static;',
'',
'        exception when no_data_found then ',
'                begin',
'                    insert into carbonita_calls (tag)',
'                        values (''no template'');',
'                end ;',
'        end;',
'',
'    end carbonita_pkg_get_report_template;',
'      PROCEDURE carbonita_pkg_generate_report (',
'        p_template_blob     IN BLOB, ',
'        p_template_mimetype IN VARCHAR2 DEFAULT ''application/vnd.openxmlformats-officedocument.wordprocessingml.document'',',
'',
'        p_report_data        IN CLOB, -- json data to send',
'        p_report_name        IN VARCHAR2 DEFAULT ''result'', -- report name',
'        p_report_type        IN VARCHAR2 DEFAULT ''pdf'', -- report type',
'        p_url               IN VARCHAR2 ,--DEFAULT const_nodejs_url,-- nodejs server url where to  POST',
'',
'        out_blob            OUT BLOB,-- generated report as blob',
'        out_mimetype        OUT VARCHAR2,',
'        out_filename        OUT VARCHAR2,',
'        out_size            OUT NUMBER --??             ',
'    ) as',
'        l_req_body CLOB;',
'',
'    begin',
'',
'            BEGIN -- build request body',
'                l_req_body :=   carbonita_priv_build_req_body(',
'                                    req_encoding            => const_req_encoding, ',
'',
'                                    req_template_blob       => p_template_blob, ',
'                                    req_template_mimetype   => p_template_mimetype,--  ?? ',
'',
'                                    req_data          => p_report_data,',
'                                    req_reportname => p_report_name,',
'                                    req_reporttype => p_report_type',
'                                );',
'            EXCEPTION WHEN OTHERS THEN begin',
'                    NULL;',
'                    end;',
'            END;',
'',
'        BEGIN -- post request and retrieve filename                     ',
'                --old version before 2/12/2020',
'            carbonita_priv_post_req(',
'                        req_body => l_req_body, ',
'                        req_url => p_url, ',
'                            out_blob => out_blob, ',
'                            out_mimetype => out_mimetype, ',
'                            out_filename => out_filename,',
'                            out_size => out_size',
'                    );',
'           -- insert into carbonita_calls (tag, req_data_clob,req_template_blob, result_blob)',
'           --             values (''generate report'',p_report_data, p_template_blob,out_blob ); commit;',
'            NULL;',
'            BEGIN',
'                NULL;',
'            END;',
'        EXCEPTION  WHEN OTHERS THEN',
'                BEGIN',
'                    ---insert into tmp1 (n,d, col1)values (1.2 , sysdate, dbms_lob.getlength(l_req_body)); commit;',
'--                    begin',
'--                    insert into carbonita_calls (tag, req_data_clob,req_template_blob, result_blob)',
'--                        values (''generate report'',p_report_data, p_template_blob,null ); commit;',
'--                    end ;',
'                    apex_json.open_object;',
'                    apex_json.write(sqlerrm);',
'                    apex_json.close_object;',
'                    htp.p(''wrong'');',
'                    htp.p(sqlerrm);',
'                    htp.p(p_report_data);',
'                END;',
'        END;',
'',
'',
'',
'    end carbonita_pkg_generate_report; ',
'',
'  ',
'   FUNCTION carbonita_pkg_get_data_clob (',
'        p_query_json IN VARCHAR2 DEFAULT q''#select JSON_ARRAYAGG(json_object(ename,job)) val from emp#''',
'    ) RETURN CLOB AS',
'        l_return_clob  CLOB;',
'        rc             SYS_REFCURSOR;',
'',
'    BEGIN',
'',
'        IF 1 = 1 THEN -- using  fetch',
'            BEGIN -- using  fetch',
'',
'                OPEN rc FOR p_query_json;',
'',
'                FETCH rc INTO l_return_clob;',
'                CLOSE rc;',
'            END;',
'        END IF;',
'',
'',
'',
'        RETURN l_return_clob;',
'    END carbonita_pkg_get_data_clob;',
'',
'    FUNCTION carbonita_pkg_get_data_clob ( -- with parameter',
'        p_query_json IN VARCHAR2 DEFAULT q''#select JSON_ARRAYAGG(json_object(ename,job)) val from emp where :e1 = :e2 #''',
'        ,p_parameter_holders in varchar2,',
'        p_parameter_values in varchar2,',
'        p_separator in varchar2 default '';''',
'',
'    ) RETURN CLOB AS',
'        l_return_clob  CLOB;',
'        rc             SYS_REFCURSOR;',
'            i integer;',
'            L_PLACEHOLDERS apex_t_varchar2 := apex_t_varchar2();',
'            L_VALUES       apex_t_varchar2 := apex_t_varchar2();',
'            L_DYN_CURSOR   NUMBER;',
'            l_dummy PLS_INTEGER;',
'    BEGIN',
'        begin -- loop from split parameter varchar2 TODO TOCHECK  !!!! ',
'                    if (1=1) then ',
'                        L_PLACEHOLDERS := apex_t_varchar2(); i:= 0;',
'                        for c_var in (select column_value from table(apex_string.split(p_parameter_holders,p_separator) )) loop',
'                            i:= i+1; L_PLACEHOLDERS.extend();',
'                            L_PLACEHOLDERS(i) := c_var.column_value;',
'                        end loop;',
'                        i:= 0;   L_VALUES := apex_t_varchar2();',
'                        for c_var in (select column_value from table(apex_string.split(p_parameter_values,p_separator) )) loop',
'                            i:= i+1;    L_VALUES.extend();',
'                            L_VALUES(i) := c_var.column_value;',
'                        end loop;',
'                    end if;',
'        end;',
'        IF 1 = 1 THEN -- using  fetch',
'            BEGIN -- using  biniding fetch ',
'                L_DYN_CURSOR := DBMS_SQL.OPEN_CURSOR;',
'                DBMS_SQL.PARSE(L_DYN_CURSOR, p_query_json  , DBMS_SQL.NATIVE);',
'',
'                FOR INDX IN 1..L_PLACEHOLDERS.COUNT LOOP',
'                    DBMS_SQL.BIND_VARIABLE(L_DYN_CURSOR, L_PLACEHOLDERS(INDX), L_VALUES(INDX));',
'                END LOOP;',
'',
'                L_DUMMY := DBMS_SQL.EXECUTE(L_DYN_CURSOR);',
'',
'                rc := DBMS_SQL.TO_REFCURSOR(L_DYN_CURSOR);',
'',
'                FETCH rc INTO l_return_clob;',
'                CLOSE rc;',
'            END;',
'        END IF;',
'',
'',
'',
'        RETURN l_return_clob;',
'        exception  when others then ',
'            begin',
'            --*-return ''{"error":"error parsing"}'';',
'                    apex_json.open_object;',
'                    apex_json.write(sqlerrm);',
'                    apex_json.close_object;',
'            end;',
'        --sqlerrm',
'    END carbonita_pkg_get_data_clob; -- with parameters',
'',
'    FUNCTION carbonita_plugin_da_render (',
'        p_dynamic_action IN apex_plugin.t_dynamic_action,',
'        p_plugin         IN apex_plugin.t_plugin',
'    ) RETURN apex_plugin.t_dynamic_action_render_result AS',
'',
'        l_da_render_result         apex_plugin.t_dynamic_action_render_result;',
'        l_server_url               VARCHAR2(4000) := p_plugin.attribute_01;',
'        l_data_json_query          VARCHAR2(4000) := p_dynamic_action.attribute_01;',
'        l_templatefilename         VARCHAR2(4000) := p_dynamic_action.attribute_02; -- template_filename -- text',
'          --  v(p_dynamic_action.attribute_05); --select static template -- item containt filename',
'',
'        l_report_type              VARCHAR2(4000) := p_dynamic_action.attribute_03;',
'        l_report_name              VARCHAR2(4000) := p_dynamic_action.attribute_04;',
'        l_templatefilename_as_item VARCHAR2(4000) := p_dynamic_action.attribute_05;',
'        l_reporttype_as_item       VARCHAR2(4000) := p_dynamic_action.attribute_06;',
'        l_query_parameters         VARCHAR2(4000) := p_dynamic_action.attribute_07;',
'        l_query_values             VARCHAR2(4000) := p_dynamic_action.attribute_08;',
'        l_query_values_item        VARCHAR2(4000) := p_dynamic_action.attribute_09;',
'    BEGIN',
'        apex_plugin_util.debug_dynamic_action(p_plugin => p_plugin, p_dynamic_action => p_dynamic_action);',
'        apex_javascript.add_library(p_name => ''FileSaver'', p_directory => p_plugin.file_prefix, p_check_to_add_minified => true);',
'',
'        apex_javascript.add_library(p_name => ''carbonita'', p_directory => p_plugin.file_prefix, p_check_to_add_minified => true);',
'',
'        NULL;',
'        l_da_render_result.javascript_function := ''carbonita_js.dothejob'';',
'        l_da_render_result.ajax_identifier := apex_plugin.get_ajax_identifier; ',
'',
'		--L_RESULT.ATTRIBUTE_01 := l_server_url;--''not your business''; --',
'        --L_RESULT.ATTRIBUTE_05 := l_data_json_query;',
'',
'        -- Parameter sent to carbonita_js',
'        l_da_render_result.attribute_01 := l_templatefilename;',
'        l_da_render_result.attribute_02 := l_report_type;',
'        l_da_render_result.attribute_03 := l_report_name;',
'        l_da_render_result.attribute_04 := l_templatefilename_as_item; -- item not available to plsql but is for js',
'        l_da_render_result.attribute_05 := l_reporttype_as_item;-- item not available to plsql but is for js',
'',
'        l_da_render_result.attribute_06 := l_query_parameters;',
'        l_da_render_result.attribute_07 := l_query_values;',
'        l_da_render_result.attribute_08 := l_query_values_item;',
'        RETURN l_da_render_result;',
'    END carbonita_plugin_da_render;',
'',
'    FUNCTION carbonita_plugin_da_ajax (',
'        p_dynamic_action IN apex_plugin.t_dynamic_action,',
'        p_plugin         IN apex_plugin.t_plugin',
'    ) RETURN apex_plugin.t_dynamic_action_ajax_result AS ',
'',
' -- plugin attributes',
'        l_da_ajax_result            apex_plugin.t_dynamic_action_ajax_result;',
'  -- other vars',
'',
'',
'        l_plg_server_url            VARCHAR2(250) := p_plugin.attribute_01; --safer than apex_application.g_x01;',
'        l_plg_separator             VARCHAR2(250) := p_plugin.attribute_02;',
'        l_da_attr_query_return_json VARCHAR2(4000) := p_dynamic_action.attribute_01; --TOCHECK TODO check how dangerous  than apex_application.g_x05;',
'',
'',
'        -- the following are called from carbonita_js ===> TOCHECK',
'        l_js_attr_template_static   VARCHAR2(250) := apex_application.g_x01;         -- TO check context',
'        l_js_attr_report_type       VARCHAR2(250) := lower(apex_application.g_x02);  -- TO check context',
'        l_js_attr_report_name       VARCHAR2(250) := apex_application.g_x03;         -- TO check context',
'        l_js_attr_ptrs_names        VARCHAR2(250) := apex_application.g_x04;         -- TO check context',
'        l_js_attr_ptrs_values       VARCHAR2(250) := apex_application.g_x05;         -- TO check context',
'        ------------------------------------------------------------',
'',
'',
'',
'',
'        l_template_blob             BLOB;',
'        l_template_mimetype         VARCHAR2(250);',
'        l_data_clob                 CLOB;',
'        l_generated_filename        VARCHAR2(255);',
'        l_generated_mimetype        VARCHAR2(255);',
'        l_generated_blob            BLOB;',
'        l_generated_size            NUMBER;',
'',
'',
'  --',
'    BEGIN',
'BEGIN -- prepare  template',
'',
'    carbonita_pkg_get_report_template(p_template_static => l_js_attr_template_static, p_app_id => v(''APP_ID''), out_template_blob => l_template_blob',
'',
'    , out_template_mimetype => l_template_mimetype);',
'EXCEPTION',
'    WHEN OTHERS THEN',
'        BEGIN',
'            message_error(l_js_attr_template_static, sqlerrm);',
'        END;',
'END;',
'',
'BEGIN -- prepare data    ',
'            --begin insert into carbonita_test(column1) values (l_plg_ptres_values);commit; end;',
'    l_data_clob := carbonita_pkg_get_data_clob(p_query_json => l_da_attr_query_return_json, p_parameter_holders => l_js_attr_ptrs_names',
'    , p_parameter_values => l_js_attr_ptrs_values, p_separator => '';'');',
'EXCEPTION',
'    WHEN OTHERS THEN',
'        BEGIN',
'            message_error(l_da_attr_query_return_json, sqlerrm);',
'        END;',
'END;',
'',
'BEGIN -- generate report',
'    carbonita_pkg_generate_report(p_url => l_plg_server_url, --const_nodejs_url,--nvl(,),',
'     p_template_blob => l_template_blob, p_template_mimetype => l_template_mimetype, p_report_data => l_data_clob, p_report_name => l_js_attr_report_name',
'    , --''plugin11'', --l_reportname,',
'                                 p_report_type => l_js_attr_report_type, out_blob => l_generated_blob, out_mimetype => l_generated_mimetype',
'                                 , out_filename => l_generated_filename, out_size => l_generated_size);',
'         --insert into tmp2 (d,dataclob,templateblob) values(sysdate, l_data_clob,l_generated_blob);commit;',
'EXCEPTION',
'    WHEN OTHERS THEN',
'        BEGIN',
'            message_error(l_data_clob, sqlerrm);',
'        END;',
'END;',
'',
'BEGIN -- ???option 1 download from plsql option 2 download from js ',
'              -- TOCHECK  ',
'    IF 1 = 2 THEN',
'        BEGIN     -- if the download apex',
'            sys.htp.flush;',
'            sys.htp.init;',
'            sys.owa_util.mime_header(l_generated_mimetype, false);',
'            sys.htp.p(''Content-length: ''',
'                      || sys.dbms_lob.getlength(l_generated_blob));',
'',
'            sys.htp.p(''Content-Disposition: attachment; filename="''',
'                      || l_generated_filename',
'                      || ''"'');',
'            sys.htp.p(''Cache-Control: no-cache '');  -- tell the browser to cache for one hour, adjust as necessary',
'            sys.owa_util.http_header_close;',
'            sys.wpg_docload.download_file(l_generated_blob);',
'            apex_application.stop_apex_engine;',
'                  --  dbms_lob.freetemporary(l_generated_blob);',
'        EXCEPTION -- when other then apex_application.stop_apex_engine;',
'            WHEN apex_application.e_stop_apex_engine THEN',
'                htp.p(''process error'');',
'        END;',
'    ELSE',
'        BEGIN -- use filesaver from js',
'',
'            apex_json.initialize_output(p_http_header => true);',
'            apex_json.flush;',
'            apex_json.open_object;',
'            apex_json.write(''status'', ''success'');',
'            apex_json.write(''download'', ''js'');',
'            apex_json.open_object(''reportgenerated'');',
'            apex_json.write(''mimetype'', l_generated_mimetype);',
'            apex_json.write(''filename'', l_generated_filename);',
'            apex_json.write(''base64'',--  ''SGVsbG8gV29ybGQ=''); ',
'             apex_web_service.blob2clobbase64(l_generated_blob));',
'            apex_json.close_object;',
'            apex_json.close_object;',
'        END;',
'    END IF;',
'',
'    end;',
'    RETURN l_da_ajax_result;',
'END carbonita_plugin_da_ajax;',
'',
' '))
,p_api_version=>2
,p_render_function=>'carbonita_plugin_da_render'
,p_ajax_function=>'carbonita_plugin_da_ajax'
,p_standard_attributes=>'ITEM:STOP_EXECUTION_ON_ERROR:WAIT_FOR_RESULT'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<h3>PL/SQL Code</h3><p>Enter the PL/SQL code to be executed.</p><h4>Examples</h4><p>',
'</p><dl><dt>Increases the salary by 3% for those employees which are qualified for a salary raise:</dt>',
'<dd><pre>begin',
'    for l_emp ( select empno',
'                  from emp',
'                 where deptno = :P2_DEPTNO )',
'    loop',
'        if needs_salary_raise( l_empno.empno ) then',
'            update emp',
'               set sal = sal * 1.03',
'             where empno = l_emp.empno;',
'        end if;',
'    end loop;',
'end;',
'</pre></dd>',
'</dl><p></p><h4>Additional Information</h4><ul><li>Type: PL/SQL Code</li><li>Supported Bind Variables: Application, Page Items and System Variables</li></ul>'))
,p_version_identifier=>'0.7'
,p_files_version=>127
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(48753260031997048)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'node_js_url'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'http://10.1.1.142:8000/'
,p_is_translatable=>false
,p_help_text=>'url where nodejs is installed'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(32407176030403736)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'plugin_separator'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>';'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(32002849985106195)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>100
,p_prompt=>'json_data_query'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_default_value=>'select JSON_ARRAYAGG(json_object(ename,job)) val from emp'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(32005349411111039)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>110
,p_prompt=>'template_static'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(51047527487894377)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>130
,p_prompt=>'report_type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'docx'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(51051380312913989)
,p_plugin_attribute_id=>wwv_flow_imp.id(51047527487894377)
,p_display_sequence=>10
,p_display_value=>'docx'
,p_return_value=>'docx'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(51054336651918554)
,p_plugin_attribute_id=>wwv_flow_imp.id(51047527487894377)
,p_display_sequence=>15
,p_display_value=>'pdf'
,p_return_value=>'pdf'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(51051756883914651)
,p_plugin_attribute_id=>wwv_flow_imp.id(51047527487894377)
,p_display_sequence=>20
,p_display_value=>'txt'
,p_return_value=>'txt'
);
end;
/
begin
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(51052242420915486)
,p_plugin_attribute_id=>wwv_flow_imp.id(51047527487894377)
,p_display_sequence=>30
,p_display_value=>'xlsx'
,p_return_value=>'xlsx'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(51052584785916068)
,p_plugin_attribute_id=>wwv_flow_imp.id(51047527487894377)
,p_display_sequence=>40
,p_display_value=>'html'
,p_return_value=>'html'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(51052971254916675)
,p_plugin_attribute_id=>wwv_flow_imp.id(51047527487894377)
,p_display_sequence=>50
,p_display_value=>'pptx'
,p_return_value=>'pptx'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(32006306449112624)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>140
,p_prompt=>'report_name'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(12600562670048801)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>120
,p_prompt=>'template_static_item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(32005349411111039)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NULL'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13203425779399111)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>135
,p_prompt=>'report_type_item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(51047527487894377)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NULL'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(14206607555518389)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>150
,p_prompt=>'query_parameters'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(14207513713519228)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>160
,p_prompt=>'query_values'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(15007341245766129)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>170
,p_prompt=>'query_values_item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(50729064960802551)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_name=>'carbonita-data-generated'
,p_display_name=>'carbonita data generated'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(50729822147802554)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_name=>'carbonita-data-sent'
,p_display_name=>'carbonita data sent to nodejs'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(50730566588802555)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_name=>'carbonita-report-error-01'
,p_display_name=>'carbonita event 05'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(50730189618802554)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_name=>'carbonita-report-received'
,p_display_name=>'carbonita Report Received from nodejs'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(50729381811802553)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_name=>'carbonita-template-sent'
,p_display_name=>'carbonita Template sent to nodejs'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '7661722074686576617266756E6374696F6E3D7B626173653634746F426C6F623A66756E6374696F6E286F2C65297B666F7228766172206E3D61746F62286F292C743D652C723D6E6577204172726179427566666572286E2E6C656E677468292C6C3D6E';
wwv_flow_imp.g_varchar2_table(2) := '65772055696E743841727261792872292C613D303B613C6E2E6C656E6774683B612B2B296C5B615D3D6E2E63686172436F646541742861293B7472797B72657475726E206E657720426C6F62285B725D2C7B747970653A747D297D6361746368286F297B';
wwv_flow_imp.g_varchar2_table(3) := '76617220693D6E65772877696E646F772E5765624B6974426C6F624275696C6465727C7C77696E646F772E4D6F7A426C6F624275696C6465727C7C77696E646F772E4D53426C6F624275696C646572293B72657475726E20692E617070656E642872292C';
wwv_flow_imp.g_varchar2_table(4) := '692E676574426C6F622874297D7D2C646F7468656A6F623A66756E6374696F6E28297B636F6E736F6C652E6C6F6728226C6175636865642122293B766172206F3D746869732C653D6F2E616374696F6E2E616A61784964656E7469666965722C6E3D6F2E';
wwv_flow_imp.g_varchar2_table(5) := '616374696F6E2E61747472696275746530312C743D6F2E616374696F6E2E61747472696275746530322C723D6F2E616374696F6E2E61747472696275746530333B636F6E736F6C652E6C6F672822765F7265706F72745F74797065203A222B74292C636F';
wwv_flow_imp.g_varchar2_table(6) := '6E736F6C652E6C6F672822765F74656D706C6174655F66696C656E616D65203A222B6E292C636F6E736F6C652E6C6F672822765F7265706F72745F6E616D65203A222B72292C617065782E7365727665722E706C7567696E28652C7B7830313A6E2C7830';
wwv_flow_imp.g_varchar2_table(7) := '323A742C7830333A727D2C7B737563636573733A66756E6374696F6E286F297B636F6E736F6C652E6C6F67282277616974696E6722292C636F6E736F6C652E6C6F67286F293B76617220653D74686576617266756E6374696F6E2E626173653634746F42';
wwv_flow_imp.g_varchar2_table(8) := '6C6F6228226956424F5277304B47676F414141414E53556845556741414141554141414146434159414141434E6279626C4141414148456C4551565149313250342F2F382F773338474941584449424B4530444878676C6A4E4241414F3954584C305934';
wwv_flow_imp.g_varchar2_table(9) := '4F487741414141424A52553545726B4A6767673D3D222C22696D6167652F706E6722293B226A73223D3D3D6F2E646F776E6C6F6164262673617665417328652C22777A6C6F7522297D2C6572726F723A66756E6374696F6E286F2C65297B242822626F64';
wwv_flow_imp.g_varchar2_table(10) := '7922292E747269676765722822636172626F6E6974612D7265706F72742D6572726F722D303122292C636F6E736F6C652E6C6F672822646F7468656A6F623A20617065782E7365727665722E706C7567696E204552524F523A222C65297D2C616C776179';
wwv_flow_imp.g_varchar2_table(11) := '733A66756E6374696F6E28297B636F6E736F6C652E6C6F6728226E6F2066756E22297D7D297D7D3B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(10203601738794068)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_file_name=>'testjs.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A212040736F7572636520687474703A2F2F7075726C2E656C69677265792E636F6D2F6769746875622F46696C6553617665722E6A732F626C6F622F6D61737465722F46696C6553617665722E6A73202A2F0A766172207361766541733D7361766541';
wwv_flow_imp.g_varchar2_table(2) := '737C7C66756E6374696F6E2865297B2275736520737472696374223B6966282128766F696420303D3D3D657C7C22756E646566696E656422213D747970656F66206E6176696761746F7226262F4D534945205B312D395D5C2E2F2E74657374286E617669';
wwv_flow_imp.g_varchar2_table(3) := '6761746F722E757365724167656E742929297B76617220743D652E646F63756D656E742C6E3D66756E6374696F6E28297B72657475726E20652E55524C7C7C652E7765626B697455524C7C7C657D2C6F3D742E637265617465456C656D656E744E532822';
wwv_flow_imp.g_varchar2_table(4) := '687474703A2F2F7777772E77332E6F72672F313939392F7868746D6C222C226122292C723D22646F776E6C6F616422696E206F2C613D2F636F6E7374727563746F722F692E7465737428652E48544D4C456C656D656E74297C7C652E7361666172692C69';
wwv_flow_imp.g_varchar2_table(5) := '3D2F4372694F535C2F5B5C645D2B2F2E74657374286E6176696761746F722E757365724167656E74292C643D66756E6374696F6E2874297B28652E736574496D6D6564696174657C7C652E73657454696D656F757429282866756E6374696F6E28297B74';
wwv_flow_imp.g_varchar2_table(6) := '68726F7720747D292C30297D2C733D66756E6374696F6E2865297B73657454696D656F7574282866756E6374696F6E28297B22737472696E67223D3D747970656F6620653F6E28292E7265766F6B654F626A65637455524C2865293A652E72656D6F7665';
wwv_flow_imp.g_varchar2_table(7) := '28297D292C346534297D2C663D66756E6374696F6E2865297B72657475726E2F5E5C732A283F3A746578745C2F5C532A7C6170706C69636174696F6E5C2F786D6C7C5C532A5C2F5C532A5C2B786D6C295C732A3B2E2A636861727365745C732A3D5C732A';
wwv_flow_imp.g_varchar2_table(8) := '7574662D382F692E7465737428652E74797065293F6E657720426C6F62285B537472696E672E66726F6D43686172436F6465283635323739292C655D2C7B747970653A652E747970657D293A657D2C753D66756E6374696F6E28742C752C63297B637C7C';
wwv_flow_imp.g_varchar2_table(9) := '28743D66287429293B766172206C2C703D746869732C763D226170706C69636174696F6E2F6F637465742D73747265616D223D3D3D742E747970652C773D66756E6374696F6E28297B2166756E6374696F6E28652C742C6E297B666F7228766172206F3D';
wwv_flow_imp.g_varchar2_table(10) := '28743D5B5D2E636F6E636174287429292E6C656E6774683B6F2D2D3B297B76617220723D655B226F6E222B745B6F5D5D3B6966282266756E6374696F6E223D3D747970656F662072297472797B722E63616C6C28652C6E7C7C65297D6361746368286529';
wwv_flow_imp.g_varchar2_table(11) := '7B642865297D7D7D28702C22777269746573746172742070726F6772657373207772697465207772697465656E64222E73706C69742822202229297D3B696628702E726561647953746174653D702E494E49542C722972657475726E206C3D6E28292E63';
wwv_flow_imp.g_varchar2_table(12) := '72656174654F626A65637455524C2874292C766F69642073657454696D656F7574282866756E6374696F6E28297B76617220652C743B6F2E687265663D6C2C6F2E646F776E6C6F61643D752C653D6F2C743D6E6577204D6F7573654576656E742822636C';
wwv_flow_imp.g_varchar2_table(13) := '69636B22292C652E64697370617463684576656E742874292C7728292C73286C292C702E726561647953746174653D702E444F4E457D29293B2166756E6374696F6E28297B69662828697C7C76262661292626652E46696C65526561646572297B766172';
wwv_flow_imp.g_varchar2_table(14) := '206F3D6E65772046696C655265616465723B72657475726E206F2E6F6E6C6F6164656E643D66756E6374696F6E28297B76617220743D693F6F2E726573756C743A6F2E726573756C742E7265706C616365282F5E646174613A5B5E3B5D2A3B2F2C226461';
wwv_flow_imp.g_varchar2_table(15) := '74613A6174746163686D656E742F66696C653B22293B652E6F70656E28742C225F626C616E6B22297C7C28652E6C6F636174696F6E2E687265663D74292C743D766F696420302C702E726561647953746174653D702E444F4E452C7728297D2C6F2E7265';
wwv_flow_imp.g_varchar2_table(16) := '616441734461746155524C2874292C766F696428702E726561647953746174653D702E494E4954297D286C7C7C286C3D6E28292E6372656174654F626A65637455524C287429292C76293F652E6C6F636174696F6E2E687265663D6C3A652E6F70656E28';
wwv_flow_imp.g_varchar2_table(17) := '6C2C225F626C616E6B22297C7C28652E6C6F636174696F6E2E687265663D6C293B702E726561647953746174653D702E444F4E452C7728292C73286C297D28297D2C633D752E70726F746F747970653B72657475726E22756E646566696E656422213D74';
wwv_flow_imp.g_varchar2_table(18) := '7970656F66206E6176696761746F7226266E6176696761746F722E6D73536176654F724F70656E426C6F623F66756E6374696F6E28652C742C6E297B72657475726E20743D747C7C652E6E616D657C7C22646F776E6C6F6164222C6E7C7C28653D662865';
wwv_flow_imp.g_varchar2_table(19) := '29292C6E6176696761746F722E6D73536176654F724F70656E426C6F6228652C74297D3A28632E61626F72743D66756E6374696F6E28297B7D2C632E726561647953746174653D632E494E49543D302C632E57524954494E473D312C632E444F4E453D32';
wwv_flow_imp.g_varchar2_table(20) := '2C632E6572726F723D632E6F6E777269746573746172743D632E6F6E70726F67726573733D632E6F6E77726974653D632E6F6E61626F72743D632E6F6E6572726F723D632E6F6E7772697465656E643D6E756C6C2C66756E6374696F6E28652C742C6E29';
wwv_flow_imp.g_varchar2_table(21) := '7B72657475726E206E6577207528652C747C7C652E6E616D657C7C22646F776E6C6F6164222C6E297D297D7D2822756E646566696E656422213D747970656F662073656C66262673656C667C7C22756E646566696E656422213D747970656F662077696E';
wwv_flow_imp.g_varchar2_table(22) := '646F77262677696E646F777C7C746869732E636F6E74656E74293B22756E646566696E656422213D747970656F66206D6F64756C6526266D6F64756C652E6578706F7274733F6D6F64756C652E6578706F7274732E7361766541733D7361766541733A22';
wwv_flow_imp.g_varchar2_table(23) := '756E646566696E656422213D747970656F6620646566696E6526266E756C6C213D3D646566696E6526266E756C6C213D3D646566696E652E616D642626646566696E65282246696C6553617665722E6A73222C2866756E6374696F6E28297B7265747572';
wwv_flow_imp.g_varchar2_table(24) := '6E207361766541737D29293B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(10204672016814129)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_file_name=>'FileSaver.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2F2076657273696F6E20302E322E3030320D0A0D0A7661722074686576617266756E6374696F6E203D207B0D0A2020626173653634746F426C6F623A2066756E6374696F6E2028704261736536342C20704D696D655479706529207B0D0A2020202076';
wwv_flow_imp.g_varchar2_table(2) := '61722062797465537472696E67203D2061746F622870426173653634293B0D0A2020200D0A2020202020766172206D696D65537472696E67203D20704D696D65547970653B0D0A20202020202F2F20777269746520746865206279746573206F66207468';
wwv_flow_imp.g_varchar2_table(3) := '6520737472696E6720746F20616E2041727261794275666665720D0A2020202020766172206162203D206E65772041727261794275666665722862797465537472696E672E6C656E677468293B0D0A2020202020766172206961203D206E65772055696E';
wwv_flow_imp.g_varchar2_table(4) := '74384172726179286162293B0D0A2020202020666F7220287661722069203D20303B2069203C2062797465537472696E672E6C656E6774683B20692B2B29207B0D0A2020202020202069615B695D203D2062797465537472696E672E63686172436F6465';
wwv_flow_imp.g_varchar2_table(5) := '41742869293B0D0A20202020207D0D0A20202020202F2F2077726974652074686520417272617942756666657220746F206120626C6F620D0A2020202020747279207B0D0A202020202020202F2F20426C6F62204D6574686F640D0A2020202020202072';
wwv_flow_imp.g_varchar2_table(6) := '657475726E206E657720426C6F62285B61625D2C207B0D0A202020202020202020747970653A206D696D65537472696E670D0A202020202020207D293B0D0A20202020207D20636174636820286529207B0D0A202020202020202F2F2064657072656361';
wwv_flow_imp.g_varchar2_table(7) := '74656420426C6F624275696C646572204D6574686F640D0A2020202020202076617220426C6F624275696C646572203D2077696E646F772E5765624B6974426C6F624275696C646572207C7C2077696E646F772E4D6F7A426C6F624275696C646572207C';
wwv_flow_imp.g_varchar2_table(8) := '7C2077696E646F772E4D53426C6F624275696C6465723B0D0A20202020202020766172206262203D206E657720426C6F624275696C64657228293B0D0A2020202020202062622E617070656E64286162293B0D0A2020202020202072657475726E206262';
wwv_flow_imp.g_varchar2_table(9) := '2E676574426C6F62286D696D65537472696E67293B0D0A20202020207D0D0A2020207D2C0D0A0D0A2020646F7468656A6F623A2066756E6374696F6E202829207B202F2F6461436F6E746578742C206F7074696F6E730D0A0D0A20202020636F6E736F6C';
wwv_flow_imp.g_varchar2_table(10) := '652E6C6F6728276C6175636865642127293B0D0A2020202076617220646154686973203D20746869733B0D0A202020202F2F3F2074726967676572203D202223222B746869732E74726967676572696E67456C656D656E742E69643B0D0A0D0A20202020';
wwv_flow_imp.g_varchar2_table(11) := '76617220765F416A61784964656E746966696572203D206461546869732E616374696F6E2E616A61784964656E7469666965723B0D0A2020202076617220765F74656D706C6174655F66696C656E616D65203D206461546869732E616374696F6E2E6174';
wwv_flow_imp.g_varchar2_table(12) := '7472696275746530313B0D0A2020202076617220765F7265706F72745F74797065203D206461546869732E616374696F6E2E61747472696275746530323B0D0A2020202076617220765F7265706F72745F6E616D65203D206461546869732E616374696F';
wwv_flow_imp.g_varchar2_table(13) := '6E2E61747472696275746530333B0D0A0D0A202020202F2F7661722076486569676874203D207061727365496E74286461546869732E616374696F6E2E6174747269627574653036293B0D0A202020202F2F76617220764C657474657252656E64657269';
wwv_flow_imp.g_varchar2_table(14) := '6E67203D206170657853637265656E436170747572652E7061727365426F6F6C65616E286461546869732E616374696F6E2E6174747269627574653037293B0D0A0D0A20202020636F6E736F6C652E6C6F672827765F7265706F72745F74797065203A27';
wwv_flow_imp.g_varchar2_table(15) := '202B20765F7265706F72745F74797065293B0D0A20202020636F6E736F6C652E6C6F672827765F74656D706C6174655F66696C656E616D65203A27202B20765F74656D706C6174655F66696C656E616D65293B0D0A20202020636F6E736F6C652E6C6F67';
wwv_flow_imp.g_varchar2_table(16) := '2827765F7265706F72745F6E616D65203A27202B20765F7265706F72745F6E616D65293B0D0A0D0A0D0A202020202F2F204150455820416A61782043616C6C0D0A20202020617065782E7365727665722E706C7567696E28765F416A61784964656E7469';
wwv_flow_imp.g_varchar2_table(17) := '666965722C207B0D0A0D0A2020202020207830313A20765F74656D706C6174655F66696C656E616D652C0D0A2020202020207830323A20765F7265706F72745F747970652C0D0A2020202020207830333A20765F7265706F72745F6E616D650D0A0D0A0D';
wwv_flow_imp.g_varchar2_table(18) := '0A2020202020202F2F20706167654974656D733A20222350315F444550544E4F2C2350315F454D504E4F220D0A0D0A202020207D2C207B0D0A2020202020202F2F726566726573684F626A6563743A20222350315F4D595F4C495354222C0D0A20202020';
wwv_flow_imp.g_varchar2_table(19) := '20202F2F6C6F6164696E67496E64696361746F723A20222350315F4D595F4C495354222C0D0A202020202020737563636573733A2066756E6374696F6E20284461746146726F6D416A617829207B0D0A2020202020202020636F6E736F6C652E6C6F6728';
wwv_flow_imp.g_varchar2_table(20) := '2777616974696E6727293B0D0A2020202020202020636F6E736F6C652E6C6F67284461746146726F6D416A6178293B0D0A20202020202020202F2F636F6E736F6C652E6C6F67284461746146726F6D416A6178293B200D0A0D0A20202020202020207661';
wwv_flow_imp.g_varchar2_table(21) := '7220785F7265706F72745F6D696D65747970652020203D202027696D6167652F706E67273B0D0A2020202020202020202020202020202020202020202020202020202020202020202020202F2F4461746146726F6D416A61782E7265706F727467656E65';
wwv_flow_imp.g_varchar2_table(22) := '72617465642E6D696D65747970653B0D0A202020202020202076617220785F7265706F72745F66696C656E616D652020203D202027777A6C6F75273B200D0A2020202020202020202020202020202020202020202020202020202020202020202020202F';
wwv_flow_imp.g_varchar2_table(23) := '2F4461746146726F6D416A61782E7265706F727467656E6572617465642E66696C656E616D653B0D0A202020202020202076617220785F7265706F72745F62617365363420202020203D2020276956424F5277304B47676F414141414E53556845556741';
wwv_flow_imp.g_varchar2_table(24) := '414141554141414146434159414141434E6279626C4141414148456C4551565149313250342F2F382F773338474941584449424B4530444878676C6A4E4241414F3954584C3059344F487741414141424A52553545726B4A6767673D3D273B200D0A2020';
wwv_flow_imp.g_varchar2_table(25) := '202020202020202020202020202020202020202020202020202020202020202020202F2F4461746146726F6D416A61782E7265706F727467656E6572617465642E6261736536343B20200D0A202020202020202F2F20636F6E736F6C652E6C6F67282766';
wwv_flow_imp.g_varchar2_table(26) := '696C656E616D6527202B20785F7265706F72745F66696C656E616D65293B200D0A2020202020202020766172207265706F7274626C6F62202020202020202020203D202074686576617266756E6374696F6E2E626173653634746F426C6F6228785F7265';
wwv_flow_imp.g_varchar2_table(27) := '706F72745F6261736536342C20785F7265706F72745F6D696D6574797065293B0D0A2020202020202020696620284461746146726F6D416A61782E646F776E6C6F6164203D3D3D20276A732729207B0D0A20202020202020202020736176654173287265';
wwv_flow_imp.g_varchar2_table(28) := '706F7274626C6F622C20785F7265706F72745F66696C656E616D65293B0D0A20202020202020207D0D0A0D0A2020202020207D2C0D0A2020202020206572726F723A2066756E6374696F6E20287868722C20704D65737361676529207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(29) := '2020202F2F206164642061706578206576656E740D0A2020202020202020242827626F647927292E747269676765722827636172626F6E6974612D7265706F72742D6572726F722D303127293B0D0A2020202020202020200D0A2020202020202020636F';
wwv_flow_imp.g_varchar2_table(30) := '6E736F6C652E6C6F672827646F7468656A6F623A20617065782E7365727665722E706C7567696E204552524F523A272C20704D657373616765293B0D0A20202020202020202F2F2063616C6C6261636B28293B0D0A2020202020207D2C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(31) := '20616C77617973203A2066756E6374696F6E20282029207B0D0A20202020202020200D0A202020202020202020636F6E736F6C652E6C6F6728276E6F2066756E272020293B200D0A2020202020202020200D0A2020202020207D0D0A202020207D293B0D';
wwv_flow_imp.g_varchar2_table(32) := '0A0D0A0D0A20207D0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(33701256195200848)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_file_name=>'testjs.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '76617220636172626F6E6974615F6A733D7B626173653634746F426C6F623A66756E6374696F6E28652C6F297B666F722876617220743D61746F622865292C723D6F2C613D6E657720417272617942756666657228742E6C656E677468292C6E3D6E6577';
wwv_flow_imp.g_varchar2_table(2) := '2055696E743841727261792861292C693D303B693C742E6C656E6774683B692B2B296E5B695D3D742E63686172436F646541742869293B7472797B72657475726E206E657720426C6F62285B615D2C7B747970653A727D297D63617463682865297B7661';
wwv_flow_imp.g_varchar2_table(3) := '72206C3D6E65772877696E646F772E5765624B6974426C6F624275696C6465727C7C77696E646F772E4D6F7A426C6F624275696C6465727C7C77696E646F772E4D53426C6F624275696C646572293B72657475726E206C2E617070656E642861292C6C2E';
wwv_flow_imp.g_varchar2_table(4) := '676574426C6F622872297D7D2C636C6F623241727261793A66756E6374696F6E28652C6F2C74297B6C6F6F70436F756E743D4D6174682E666C6F6F7228652E6C656E6774682F6F292B313B666F722876617220723D303B723C6C6F6F70436F756E743B72';
wwv_flow_imp.g_varchar2_table(5) := '2B2B29742E7075736828652E736C696365286F2A722C6F2A28722B312929293B72657475726E20747D2C646F7468656A6F623A66756E6374696F6E28297B636F6E736F6C652E6C6F6728226C6175636865642122293B617065782E7574696C2E73686F77';
wwv_flow_imp.g_varchar2_table(6) := '5370696E6E657228293B76617220653D746869732C6F3D652E616374696F6E2E616A61784964656E7469666965722C743D652E616374696F6E2E61747472696275746530312C723D652E616374696F6E2E61747472696275746530322C613D652E616374';
wwv_flow_imp.g_varchar2_table(7) := '696F6E2E61747472696275746530332C6E3D652E616374696F6E2E61747472696275746530342C693D652E616374696F6E2E61747472696275746530352C6C3D652E616374696F6E2E61747472696275746530362C633D652E616374696F6E2E61747472';
wwv_flow_imp.g_varchar2_table(8) := '696275746530372C733D652E616374696F6E2E61747472696275746530383B636F6E736F6C652E6C6F672822765F7265706F72745F74797065203A222B72292C636F6E736F6C652E6C6F672822765F74656D706C6174655F66696C656E616D65203A222B';
wwv_flow_imp.g_varchar2_table(9) := '74292C636F6E736F6C652E6C6F672822765F7265706F72745F6E616D65203A222B61292C636F6E736F6C652E6C6F672822765F74656D706C6174655F66696C656E616D655F66726F6D5F6974656D203A222B2476286E29292C636F6E736F6C652E6C6F67';
wwv_flow_imp.g_varchar2_table(10) := '2822765F765F7265706F7274747970655F61735F6974656D203A222B2476286929292C636F6E736F6C652E6C6F672822765F71756572795F706172616D6574657273203A222B6C292C636F6E736F6C652E6C6F672822765F765F71756572795F76616C75';
wwv_flow_imp.g_varchar2_table(11) := '65735F6974656D203A222B2476287329292C617065782E7365727665722E706C7567696E286F2C7B7830313A747C7C2476286E297C7C2273696D70652D76322E6F6474222C7830323A727C7C24762869297C7C22646F6378222C7830333A612C7830343A';
wwv_flow_imp.g_varchar2_table(12) := '6C2C7830353A24762873297C7C637D2C7B737563636573733A66756E6374696F6E2865297B636F6E736F6C652E6C6F67282277616974696E672E2E2E22292C242822626F647922292E747269676765722822636172626F6E6974612D7265706F72742D72';
wwv_flow_imp.g_varchar2_table(13) := '6563656976656422293B766172206F3D652E7265706F727467656E6572617465642E6D696D65747970652C743D652E7265706F727467656E6572617465642E66696C656E616D652C723D652E7265706F727467656E6572617465642E6261736536343B63';
wwv_flow_imp.g_varchar2_table(14) := '6F6E736F6C652E6C6F67282266696C656E616D65203A222B74293B76617220613D636172626F6E6974615F6A732E626173653634746F426C6F6228722C6F293B226A73223D3D3D652E646F776E6C6F616426262873617665417328612C74292C24282223';
wwv_flow_imp.g_varchar2_table(15) := '617065785F776169745F6F7665726C617922292E72656D6F766528292C2428222E752D50726F63657373696E6722292E72656D6F76652829297D2C6572726F723A66756E6374696F6E28652C6F297B242822626F647922292E7472696767657228226361';
wwv_flow_imp.g_varchar2_table(16) := '72626F6E6974612D7265706F72742D6572726F722D303122292C636F6E736F6C652E6C6F672822646F7468656A6F623A20617065782E7365727665722E706C7567696E204552524F523A222C6F297D7D297D7D3B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(33711260303069546)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_file_name=>'carbonita.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A2046696C6553617665722E6A730A202A20412073617665417328292046696C65536176657220696D706C656D656E746174696F6E2E0A202A20312E332E320A202A20323031362D30362D31362031383A32353A31390A202A0A202A20427920456C69';
wwv_flow_imp.g_varchar2_table(2) := '20477265792C20687474703A2F2F656C69677265792E636F6D0A202A204C6963656E73653A204D49540A202A2020205365652068747470733A2F2F6769746875622E636F6D2F656C69677265792F46696C6553617665722E6A732F626C6F622F6D617374';
wwv_flow_imp.g_varchar2_table(3) := '65722F4C4943454E53452E6D640A202A2F0A0A2F2A676C6F62616C2073656C66202A2F0A2F2A6A736C696E7420626974776973653A20747275652C20696E64656E743A20342C206C6178627265616B3A20747275652C206C6178636F6D6D613A20747275';
wwv_flow_imp.g_varchar2_table(4) := '652C20736D617274746162733A20747275652C20706C7573706C75733A2074727565202A2F0A0A2F2A212040736F7572636520687474703A2F2F7075726C2E656C69677265792E636F6D2F6769746875622F46696C6553617665722E6A732F626C6F622F';
wwv_flow_imp.g_varchar2_table(5) := '6D61737465722F46696C6553617665722E6A73202A2F0A0A76617220736176654173203D20736176654173207C7C202866756E6374696F6E287669657729207B0A092275736520737472696374223B0A092F2F204945203C3130206973206578706C6963';
wwv_flow_imp.g_varchar2_table(6) := '69746C7920756E737570706F727465640A0969662028747970656F662076696577203D3D3D2022756E646566696E656422207C7C20747970656F66206E6176696761746F7220213D3D2022756E646566696E656422202626202F4D534945205B312D395D';
wwv_flow_imp.g_varchar2_table(7) := '5C2E2F2E74657374286E6176696761746F722E757365724167656E742929207B0A090972657475726E3B0A097D0A097661720A09092020646F63203D20766965772E646F63756D656E740A090920202F2F206F6E6C79206765742055524C207768656E20';
wwv_flow_imp.g_varchar2_table(8) := '6E656365737361727920696E206361736520426C6F622E6A73206861736E2774206F76657272696464656E206974207965740A09092C206765745F55524C203D2066756E6374696F6E2829207B0A09090972657475726E20766965772E55524C207C7C20';
wwv_flow_imp.g_varchar2_table(9) := '766965772E7765626B697455524C207C7C20766965773B0A09097D0A09092C20736176655F6C696E6B203D20646F632E637265617465456C656D656E744E532822687474703A2F2F7777772E77332E6F72672F313939392F7868746D6C222C2022612229';
wwv_flow_imp.g_varchar2_table(10) := '0A09092C2063616E5F7573655F736176655F6C696E6B203D2022646F776E6C6F61642220696E20736176655F6C696E6B0A09092C20636C69636B203D2066756E6374696F6E286E6F646529207B0A090909766172206576656E74203D206E6577204D6F75';
wwv_flow_imp.g_varchar2_table(11) := '73654576656E742822636C69636B22293B0A0909096E6F64652E64697370617463684576656E74286576656E74293B0A09097D0A09092C2069735F736166617269203D202F636F6E7374727563746F722F692E7465737428766965772E48544D4C456C65';
wwv_flow_imp.g_varchar2_table(12) := '6D656E7429207C7C20766965772E7361666172690A09092C2069735F6368726F6D655F696F73203D2F4372694F535C2F5B5C645D2B2F2E74657374286E6176696761746F722E757365724167656E74290A09092C207468726F775F6F757473696465203D';
wwv_flow_imp.g_varchar2_table(13) := '2066756E6374696F6E28657829207B0A09090928766965772E736574496D6D656469617465207C7C20766965772E73657454696D656F7574292866756E6374696F6E2829207B0A090909097468726F772065783B0A0909097D2C2030293B0A09097D0A09';
wwv_flow_imp.g_varchar2_table(14) := '092C20666F7263655F7361766561626C655F74797065203D20226170706C69636174696F6E2F6F637465742D73747265616D220A09092F2F2074686520426C6F62204150492069732066756E64616D656E74616C6C792062726F6B656E20617320746865';
wwv_flow_imp.g_varchar2_table(15) := '7265206973206E6F2022646F776E6C6F616466696E697368656422206576656E7420746F2073756273637269626520746F0A09092C206172626974726172795F7265766F6B655F74696D656F7574203D2031303030202A203430202F2F20696E206D730A';
wwv_flow_imp.g_varchar2_table(16) := '09092C207265766F6B65203D2066756E6374696F6E2866696C6529207B0A090909766172207265766F6B6572203D2066756E6374696F6E2829207B0A0909090969662028747970656F662066696C65203D3D3D2022737472696E672229207B202F2F2066';
wwv_flow_imp.g_varchar2_table(17) := '696C6520697320616E206F626A6563742055524C0A09090909096765745F55524C28292E7265766F6B654F626A65637455524C2866696C65293B0A090909097D20656C7365207B202F2F2066696C6520697320612046696C650A090909090966696C652E';
wwv_flow_imp.g_varchar2_table(18) := '72656D6F766528293B0A090909097D0A0909097D3B0A09090973657454696D656F7574287265766F6B65722C206172626974726172795F7265766F6B655F74696D656F7574293B0A09097D0A09092C206469737061746368203D2066756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(19) := '66696C6573617665722C206576656E745F74797065732C206576656E7429207B0A0909096576656E745F7479706573203D205B5D2E636F6E636174286576656E745F7479706573293B0A0909097661722069203D206576656E745F74797065732E6C656E';
wwv_flow_imp.g_varchar2_table(20) := '6774683B0A0909097768696C652028692D2D29207B0A09090909766172206C697374656E6572203D2066696C6573617665725B226F6E22202B206576656E745F74797065735B695D5D3B0A0909090969662028747970656F66206C697374656E6572203D';
wwv_flow_imp.g_varchar2_table(21) := '3D3D202266756E6374696F6E2229207B0A0909090909747279207B0A0909090909096C697374656E65722E63616C6C2866696C6573617665722C206576656E74207C7C2066696C657361766572293B0A09090909097D2063617463682028657829207B0A';
wwv_flow_imp.g_varchar2_table(22) := '0909090909097468726F775F6F757473696465286578293B0A09090909097D0A090909097D0A0909097D0A09097D0A09092C206175746F5F626F6D203D2066756E6374696F6E28626C6F6229207B0A0909092F2F2070726570656E6420424F4D20666F72';
wwv_flow_imp.g_varchar2_table(23) := '205554462D3820584D4C20616E6420746578742F2A2074797065732028696E636C7564696E672048544D4C290A0909092F2F206E6F74653A20796F75722062726F777365722077696C6C206175746F6D61746963616C6C7920636F6E7665727420555446';
wwv_flow_imp.g_varchar2_table(24) := '2D313620552B4645464620746F2045462042422042460A090909696620282F5E5C732A283F3A746578745C2F5C532A7C6170706C69636174696F6E5C2F786D6C7C5C532A5C2F5C532A5C2B786D6C295C732A3B2E2A636861727365745C732A3D5C732A75';
wwv_flow_imp.g_varchar2_table(25) := '74662D382F692E7465737428626C6F622E747970652929207B0A0909090972657475726E206E657720426C6F62285B537472696E672E66726F6D43686172436F646528307846454646292C20626C6F625D2C207B747970653A20626C6F622E747970657D';
wwv_flow_imp.g_varchar2_table(26) := '293B0A0909097D0A09090972657475726E20626C6F623B0A09097D0A09092C2046696C655361766572203D2066756E6374696F6E28626C6F622C206E616D652C206E6F5F6175746F5F626F6D29207B0A09090969662028216E6F5F6175746F5F626F6D29';
wwv_flow_imp.g_varchar2_table(27) := '207B0A09090909626C6F62203D206175746F5F626F6D28626C6F62293B0A0909097D0A0909092F2F2046697273742074727920612E646F776E6C6F61642C207468656E207765622066696C6573797374656D2C207468656E206F626A6563742055524C73';
wwv_flow_imp.g_varchar2_table(28) := '0A0909097661720A09090909202066696C657361766572203D20746869730A090909092C2074797065203D20626C6F622E747970650A090909092C20666F726365203D2074797065203D3D3D20666F7263655F7361766561626C655F747970650A090909';
wwv_flow_imp.g_varchar2_table(29) := '092C206F626A6563745F75726C0A090909092C2064697370617463685F616C6C203D2066756E6374696F6E2829207B0A090909090964697370617463682866696C6573617665722C2022777269746573746172742070726F677265737320777269746520';
wwv_flow_imp.g_varchar2_table(30) := '7772697465656E64222E73706C69742822202229293B0A090909097D0A090909092F2F206F6E20616E792066696C65737973206572726F72732072657665727420746F20736176696E672077697468206F626A6563742055524C730A090909092C206673';
wwv_flow_imp.g_varchar2_table(31) := '5F6572726F72203D2066756E6374696F6E2829207B0A0909090909696620282869735F6368726F6D655F696F73207C7C2028666F7263652026262069735F736166617269292920262620766965772E46696C6552656164657229207B0A0909090909092F';
wwv_flow_imp.g_varchar2_table(32) := '2F2053616661726920646F65736E277420616C6C6F7720646F776E6C6F6164696E67206F6620626C6F622075726C730A09090909090976617220726561646572203D206E65772046696C6552656164657228293B0A0909090909097265616465722E6F6E';
wwv_flow_imp.g_varchar2_table(33) := '6C6F6164656E64203D2066756E6374696F6E2829207B0A090909090909097661722075726C203D2069735F6368726F6D655F696F73203F207265616465722E726573756C74203A207265616465722E726573756C742E7265706C616365282F5E64617461';
wwv_flow_imp.g_varchar2_table(34) := '3A5B5E3B5D2A3B2F2C2027646174613A6174746163686D656E742F66696C653B27293B0A0909090909090976617220706F707570203D20766965772E6F70656E2875726C2C20275F626C616E6B27293B0A0909090909090969662821706F707570292076';
wwv_flow_imp.g_varchar2_table(35) := '6965772E6C6F636174696F6E2E68726566203D2075726C3B0A0909090909090975726C3D756E646566696E65643B202F2F2072656C65617365207265666572656E6365206265666F7265206469737061746368696E670A0909090909090966696C657361';
wwv_flow_imp.g_varchar2_table(36) := '7665722E72656164795374617465203D2066696C6573617665722E444F4E453B0A0909090909090964697370617463685F616C6C28293B0A0909090909097D3B0A0909090909097265616465722E7265616441734461746155524C28626C6F62293B0A09';
wwv_flow_imp.g_varchar2_table(37) := '090909090966696C6573617665722E72656164795374617465203D2066696C6573617665722E494E49543B0A09090909090972657475726E3B0A09090909097D0A09090909092F2F20646F6E277420637265617465206D6F7265206F626A656374205552';
wwv_flow_imp.g_varchar2_table(38) := '4C73207468616E206E65656465640A090909090969662028216F626A6563745F75726C29207B0A0909090909096F626A6563745F75726C203D206765745F55524C28292E6372656174654F626A65637455524C28626C6F62293B0A09090909097D0A0909';
wwv_flow_imp.g_varchar2_table(39) := '09090969662028666F72636529207B0A090909090909766965772E6C6F636174696F6E2E68726566203D206F626A6563745F75726C3B0A09090909097D20656C7365207B0A090909090909766172206F70656E6564203D20766965772E6F70656E286F62';
wwv_flow_imp.g_varchar2_table(40) := '6A6563745F75726C2C20225F626C616E6B22293B0A09090909090969662028216F70656E656429207B0A090909090909092F2F204170706C6520646F6573206E6F7420616C6C6F772077696E646F772E6F70656E2C207365652068747470733A2F2F6465';
wwv_flow_imp.g_varchar2_table(41) := '76656C6F7065722E6170706C652E636F6D2F6C6962726172792F7361666172692F646F63756D656E746174696F6E2F546F6F6C732F436F6E6365707475616C2F536166617269457874656E73696F6E47756964652F576F726B696E677769746857696E64';
wwv_flow_imp.g_varchar2_table(42) := '6F7773616E64546162732F576F726B696E677769746857696E646F7773616E64546162732E68746D6C0A09090909090909766965772E6C6F636174696F6E2E68726566203D206F626A6563745F75726C3B0A0909090909097D0A09090909097D0A090909';
wwv_flow_imp.g_varchar2_table(43) := '090966696C6573617665722E72656164795374617465203D2066696C6573617665722E444F4E453B0A090909090964697370617463685F616C6C28293B0A09090909097265766F6B65286F626A6563745F75726C293B0A090909097D0A0909093B0A0909';
wwv_flow_imp.g_varchar2_table(44) := '0966696C6573617665722E72656164795374617465203D2066696C6573617665722E494E49543B0A0A0909096966202863616E5F7573655F736176655F6C696E6B29207B0A090909096F626A6563745F75726C203D206765745F55524C28292E63726561';
wwv_flow_imp.g_varchar2_table(45) := '74654F626A65637455524C28626C6F62293B0A0909090973657454696D656F75742866756E6374696F6E2829207B0A0909090909736176655F6C696E6B2E68726566203D206F626A6563745F75726C3B0A0909090909736176655F6C696E6B2E646F776E';
wwv_flow_imp.g_varchar2_table(46) := '6C6F6164203D206E616D653B0A0909090909636C69636B28736176655F6C696E6B293B0A090909090964697370617463685F616C6C28293B0A09090909097265766F6B65286F626A6563745F75726C293B0A090909090966696C6573617665722E726561';
wwv_flow_imp.g_varchar2_table(47) := '64795374617465203D2066696C6573617665722E444F4E453B0A090909097D293B0A0909090972657475726E3B0A0909097D0A0A09090966735F6572726F7228293B0A09097D0A09092C2046535F70726F746F203D2046696C6553617665722E70726F74';
wwv_flow_imp.g_varchar2_table(48) := '6F747970650A09092C20736176654173203D2066756E6374696F6E28626C6F622C206E616D652C206E6F5F6175746F5F626F6D29207B0A09090972657475726E206E65772046696C65536176657228626C6F622C206E616D65207C7C20626C6F622E6E61';
wwv_flow_imp.g_varchar2_table(49) := '6D65207C7C2022646F776E6C6F6164222C206E6F5F6175746F5F626F6D293B0A09097D0A093B0A092F2F2049452031302B20286E617469766520736176654173290A0969662028747970656F66206E6176696761746F7220213D3D2022756E646566696E';
wwv_flow_imp.g_varchar2_table(50) := '656422202626206E6176696761746F722E6D73536176654F724F70656E426C6F6229207B0A090972657475726E2066756E6374696F6E28626C6F622C206E616D652C206E6F5F6175746F5F626F6D29207B0A0909096E616D65203D206E616D65207C7C20';
wwv_flow_imp.g_varchar2_table(51) := '626C6F622E6E616D65207C7C2022646F776E6C6F6164223B0A0A09090969662028216E6F5F6175746F5F626F6D29207B0A09090909626C6F62203D206175746F5F626F6D28626C6F62293B0A0909097D0A09090972657475726E206E6176696761746F72';
wwv_flow_imp.g_varchar2_table(52) := '2E6D73536176654F724F70656E426C6F6228626C6F622C206E616D65293B0A09097D3B0A097D0A0A0946535F70726F746F2E61626F7274203D2066756E6374696F6E28297B7D3B0A0946535F70726F746F2E72656164795374617465203D2046535F7072';
wwv_flow_imp.g_varchar2_table(53) := '6F746F2E494E4954203D20303B0A0946535F70726F746F2E57524954494E47203D20313B0A0946535F70726F746F2E444F4E45203D20323B0A0A0946535F70726F746F2E6572726F72203D0A0946535F70726F746F2E6F6E77726974657374617274203D';
wwv_flow_imp.g_varchar2_table(54) := '0A0946535F70726F746F2E6F6E70726F6772657373203D0A0946535F70726F746F2E6F6E7772697465203D0A0946535F70726F746F2E6F6E61626F7274203D0A0946535F70726F746F2E6F6E6572726F72203D0A0946535F70726F746F2E6F6E77726974';
wwv_flow_imp.g_varchar2_table(55) := '65656E64203D0A09096E756C6C3B0A0A0972657475726E207361766541733B0A7D280A09202020747970656F662073656C6620213D3D2022756E646566696E6564222026262073656C660A097C7C20747970656F662077696E646F7720213D3D2022756E';
wwv_flow_imp.g_varchar2_table(56) := '646566696E6564222026262077696E646F770A097C7C20746869732E636F6E74656E740A29293B0A2F2F206073656C666020697320756E646566696E656420696E2046697265666F7820666F7220416E64726F696420636F6E74656E7420736372697074';
wwv_flow_imp.g_varchar2_table(57) := '20636F6E746578740A2F2F207768696C6520607468697360206973206E7349436F6E74656E744672616D654D6573736167654D616E616765720A2F2F207769746820616E206174747269627574652060636F6E74656E7460207468617420636F72726573';
wwv_flow_imp.g_varchar2_table(58) := '706F6E647320746F207468652077696E646F770A0A69662028747970656F66206D6F64756C6520213D3D2022756E646566696E656422202626206D6F64756C652E6578706F72747329207B0A20206D6F64756C652E6578706F7274732E73617665417320';
wwv_flow_imp.g_varchar2_table(59) := '3D207361766541733B0A7D20656C7365206966202828747970656F6620646566696E6520213D3D2022756E646566696E65642220262620646566696E6520213D3D206E756C6C292026262028646566696E652E616D6420213D3D206E756C6C2929207B0A';
wwv_flow_imp.g_varchar2_table(60) := '2020646566696E65282246696C6553617665722E6A73222C2066756E6374696F6E2829207B0A2020202072657475726E207361766541733B0A20207D293B0A7D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(48747738494929016)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_file_name=>'FileSaver.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2F2076657273696F6E20302E342E3030370D0A0D0A76617220636172626F6E6974615F6A73203D207B0D0A0D0A2020626173653634746F426C6F623A2066756E6374696F6E2028704261736536342C20704D696D655479706529207B0D0A2020202076';
wwv_flow_imp.g_varchar2_table(2) := '61722062797465537472696E67203D2061746F622870426173653634293B0D0A0D0A20202020766172206D696D65537472696E67203D20704D696D65547970653B0D0A202020202F2F20777269746520746865206279746573206F662074686520737472';
wwv_flow_imp.g_varchar2_table(3) := '696E6720746F20616E2041727261794275666665720D0A20202020766172206162203D206E65772041727261794275666665722862797465537472696E672E6C656E677468293B0D0A20202020766172206961203D206E65772055696E74384172726179';
wwv_flow_imp.g_varchar2_table(4) := '286162293B0D0A20202020666F7220287661722069203D20303B2069203C2062797465537472696E672E6C656E6774683B20692B2B29207B0D0A20202020202069615B695D203D2062797465537472696E672E63686172436F646541742869293B0D0A20';
wwv_flow_imp.g_varchar2_table(5) := '2020207D0D0A202020202F2F2077726974652074686520417272617942756666657220746F206120626C6F620D0A20202020747279207B0D0A2020202020202F2F20426C6F62204D6574686F640D0A20202020202072657475726E206E657720426C6F62';
wwv_flow_imp.g_varchar2_table(6) := '285B61625D2C207B0D0A2020202020202020747970653A206D696D65537472696E670D0A2020202020207D293B0D0A202020207D20636174636820286529207B0D0A2020202020202F2F206465707265636174656420426C6F624275696C646572204D65';
wwv_flow_imp.g_varchar2_table(7) := '74686F640D0A20202020202076617220426C6F624275696C646572203D2077696E646F772E5765624B6974426C6F624275696C646572207C7C2077696E646F772E4D6F7A426C6F624275696C646572207C7C2077696E646F772E4D53426C6F624275696C';
wwv_flow_imp.g_varchar2_table(8) := '6465723B0D0A202020202020766172206262203D206E657720426C6F624275696C64657228293B0D0A20202020202062622E617070656E64286162293B0D0A20202020202072657475726E2062622E676574426C6F62286D696D65537472696E67293B0D';
wwv_flow_imp.g_varchar2_table(9) := '0A202020207D0D0A20207D2C0D0A0D0A2020636C6F623241727261793A2066756E6374696F6E2028636C6F622C2073697A652C20617272617929207B0D0A202020206C6F6F70436F756E74203D204D6174682E666C6F6F7228636C6F622E6C656E677468';
wwv_flow_imp.g_varchar2_table(10) := '202F2073697A6529202B20313B0D0A20202020666F7220287661722069203D20303B2069203C206C6F6F70436F756E743B20692B2B29207B0D0A20202020202061727261792E7075736828636C6F622E736C6963652873697A65202A20692C2073697A65';
wwv_flow_imp.g_varchar2_table(11) := '202A202869202B20312929293B0D0A202020207D0D0A2020202072657475726E2061727261793B0D0A20207D2C0D0A0D0A0D0A2020646F7468656A6F623A2066756E6374696F6E202829207B202F2F6461436F6E746578742C206F7074696F6E730D0A0D';
wwv_flow_imp.g_varchar2_table(12) := '0A20202020636F6E736F6C652E6C6F6728276C6175636865642127293B0D0A20202020766172207370696E6E6572203D20617065782E7574696C2E73686F775370696E6E657228293B0D0A0D0A0D0A2020202076617220646154686973203D2074686973';
wwv_flow_imp.g_varchar2_table(13) := '3B0D0A202020202F2F3F2074726967676572203D202223222B746869732E74726967676572696E67456C656D656E742E69643B0D0A202020202F2F616D616E64615F646F63785F7072696E7465722E646F637853656C6563746F72286461546869732E61';
wwv_flow_imp.g_varchar2_table(14) := '6374696F6E293B0D0A202020200D0A2020202076617220765F416A61784964656E746966696572203D206461546869732E616374696F6E2E616A61784964656E7469666965723B0D0A202020202F2F20564152532072656369657665642066726F6D2072';
wwv_flow_imp.g_varchar2_table(15) := '656E6465720D0A202020202F2F76617220765F7365727665725F75726C20202020202020203D206461546869732E616374696F6E2E61747472696275746530313B206578706F73652064616E6765726F7573200D0A2020202076617220765F74656D706C';
wwv_flow_imp.g_varchar2_table(16) := '6174655F66696C656E616D65202020202020202020202020203D206461546869732E616374696F6E2E61747472696275746530313B0D0A2020202076617220765F7265706F72745F74797065202020202020202020202020202020202020203D20646154';
wwv_flow_imp.g_varchar2_table(17) := '6869732E616374696F6E2E61747472696275746530323B0D0A2020202076617220765F7265706F72745F6E616D65202020202020202020202020202020202020203D206461546869732E616374696F6E2E61747472696275746530333B0D0A2020202076';
wwv_flow_imp.g_varchar2_table(18) := '617220765F74656D706C61746566696C656E616D655F61735F6974656D2020202020203D206461546869732E616374696F6E2E61747472696275746530343B0D0A2020202076617220765F7265706F7274747970655F61735F6974656D20202020202020';
wwv_flow_imp.g_varchar2_table(19) := '20202020203D206461546869732E616374696F6E2E61747472696275746530353B0D0A202020202F2F76617220765F646174615F6A736F6E5F71756572792020203D206461546869732E616374696F6E2E61747472696275746530353B2064616E676572';
wwv_flow_imp.g_varchar2_table(20) := '6F75730D0A2020202076617220765F71756572795F706172616D657465727320202020202020202020203D206461546869732E616374696F6E2E61747472696275746530363B0D0A2020202076617220765F71756572795F76616C756573202020202020';
wwv_flow_imp.g_varchar2_table(21) := '2020202020202020203D206461546869732E616374696F6E2E61747472696275746530373B0D0A2020202076617220765F71756572795F76616C7565735F6974656D202020202020202020203D206461546869732E616374696F6E2E6174747269627574';
wwv_flow_imp.g_varchar2_table(22) := '6530383B0D0A0D0A20200D0A0D0A20202020636F6E736F6C652E6C6F672827765F7265706F72745F74797065203A27202B20765F7265706F72745F74797065293B0D0A20202020636F6E736F6C652E6C6F672827765F74656D706C6174655F66696C656E';
wwv_flow_imp.g_varchar2_table(23) := '616D65203A27202B20765F74656D706C6174655F66696C656E616D65293B0D0A20202020636F6E736F6C652E6C6F672827765F7265706F72745F6E616D65203A27202B20765F7265706F72745F6E616D65293B0D0A20202020636F6E736F6C652E6C6F67';
wwv_flow_imp.g_varchar2_table(24) := '2827765F74656D706C6174655F66696C656E616D655F66726F6D5F6974656D203A2720202B20247628765F74656D706C61746566696C656E616D655F61735F6974656D29293B0D0A20202020636F6E736F6C652E6C6F672827765F765F7265706F727474';
wwv_flow_imp.g_varchar2_table(25) := '7970655F61735F6974656D203A27202B20247628765F7265706F7274747970655F61735F6974656D29293B0D0A20202020636F6E736F6C652E6C6F672827765F71756572795F706172616D6574657273203A27202B20765F71756572795F706172616D65';
wwv_flow_imp.g_varchar2_table(26) := '74657273293B0D0A20202020636F6E736F6C652E6C6F672827765F765F71756572795F76616C7565735F6974656D203A27202B20247628765F71756572795F76616C7565735F6974656D29293B0D0A0D0A202020202F2F204150455820416A6178204361';
wwv_flow_imp.g_varchar2_table(27) := '6C6C0D0A20202020617065782E7365727665722E706C7567696E28765F416A61784964656E7469666965722C207B0D0A2020202020202F2F2064616E6765726F757320783031203A20765F7365727665725F75726C2C0D0A2020202020207830313A2076';
wwv_flow_imp.g_varchar2_table(28) := '5F74656D706C6174655F66696C656E616D6520207C7C20247628765F74656D706C61746566696C656E616D655F61735F6974656D292020207C7C202773696D70652D76322E6F6474272C0D0A2020202020207830323A20765F7265706F72745F74797065';
wwv_flow_imp.g_varchar2_table(29) := '20202020202020207C7C20247628765F7265706F7274747970655F61735F6974656D292020202020202020207C7C2027646F6378272C0D0A2020202020207830333A20765F7265706F72745F6E616D652C0D0A2020202020207830343A20765F71756572';
wwv_flow_imp.g_varchar2_table(30) := '795F706172616D65746572732C20202F2F544F4F442073686F756C6420626520612077617920746F2073656E64206173206172726179203F0D0A2020202020207830353A20247628765F71756572795F76616C7565735F6974656D29207C7C20765F7175';
wwv_flow_imp.g_varchar2_table(31) := '6572795F76616C7565730D0A20200D0A20200D0A0D0A2020202020202F2F64616E6765726F75732020783035203A20765F646174615F6A736F6E5F71756572792C0D0A20202020202F2F20706167654974656D733A20765F6974656D5F746F5F72656672';
wwv_flow_imp.g_varchar2_table(32) := '657368202F2F222350315F444550544E4F2C2350315F454D504E4F220D0A0D0A202020207D2C207B0D0A2020202020202F2F726566726573684F626A6563743A20222350315F4D595F4C495354222C0D0A2020202020202F2F6C6F6164696E67496E6469';
wwv_flow_imp.g_varchar2_table(33) := '6361746F723A20222350315F4D595F4C495354222C0D0A202020202020737563636573733A2066756E6374696F6E20284461746146726F6D416A617829207B0D0A2020202020202020636F6E736F6C652E6C6F67282777616974696E672E2E2E27293B0D';
wwv_flow_imp.g_varchar2_table(34) := '0A20202020202020200D0A2020202020202F2F2020636F6E736F6C652E6C6F67284461746146726F6D416A6178293B20202F2F2064656275670D0A20202020202020200D0A2020202020202020242827626F647927292E74726967676572282763617262';
wwv_flow_imp.g_varchar2_table(35) := '6F6E6974612D7265706F72742D726563656976656427293B0D0A202020202020202076617220785F7265706F72745F6D696D6574797065203D204461746146726F6D416A61782E7265706F727467656E6572617465642E6D696D65747970653B0D0A2020';
wwv_flow_imp.g_varchar2_table(36) := '20202020202076617220785F7265706F72745F66696C656E616D65203D204461746146726F6D416A61782E7265706F727467656E6572617465642E66696C656E616D653B0D0A202020202020202076617220785F7265706F72745F626173653634203D20';
wwv_flow_imp.g_varchar2_table(37) := '4461746146726F6D416A61782E7265706F727467656E6572617465642E6261736536343B0D0A20202020202020202F2F636F6E736F6C652E6C6F672820785F7265706F72745F62617365363420293B202F2F3D204461746146726F6D416A61782E726570';
wwv_flow_imp.g_varchar2_table(38) := '6F727467656E6572617465642E6261736536343B0D0A2020202020202020636F6E736F6C652E6C6F67282766696C656E616D65203A27202B20785F7265706F72745F66696C656E616D65293B200D0A2020202020202020766172207265706F7274626C6F';
wwv_flow_imp.g_varchar2_table(39) := '62203D20636172626F6E6974615F6A732E626173653634746F426C6F6228785F7265706F72745F6261736536342C20785F7265706F72745F6D696D6574797065293B0D0A2020202020202020696620284461746146726F6D416A61782E646F776E6C6F61';
wwv_flow_imp.g_varchar2_table(40) := '64203D3D3D20276A732729207B0D0A20202020202020202020736176654173287265706F7274626C6F622C20785F7265706F72745F66696C656E616D65293B0D0A202020202020202020200D0A2F2F72656D6F7665207370696E6E65720D0A2428222361';
wwv_flow_imp.g_varchar2_table(41) := '7065785F776169745F6F7665726C617922292E72656D6F766528293B0D0A2428222E752D50726F63657373696E6722292E72656D6F766528293B0D0A20202020202020207D0D0A20202020202020202F2F20646F20736F6D657468696E6720686572650D';
wwv_flow_imp.g_varchar2_table(42) := '0A0D0A2020202020207D2C0D0A2020202020206572726F723A2066756E6374696F6E20287868722C20704D65737361676529207B0D0A20202020202020202F2F206164642061706578206576656E740D0A2020202020202020242827626F647927292E74';
wwv_flow_imp.g_varchar2_table(43) := '7269676765722827636172626F6E6974612D7265706F72742D6572726F722D303127293B0D0A20202020202020202F2F206C6F6767696E670D0A2020202020202020636F6E736F6C652E6C6F672827646F7468656A6F623A20617065782E736572766572';
wwv_flow_imp.g_varchar2_table(44) := '2E706C7567696E204552524F523A272C20704D657373616765293B0D0A20202020202020202F2F2063616C6C6261636B28293B0D0A2020202020207D0D0A202020207D293B0D0A0D0A2020200D0A20207D0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(50836963680352910)
,p_plugin_id=>wwv_flow_imp.id(48745522732537372)
,p_file_name=>'carbonita.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
