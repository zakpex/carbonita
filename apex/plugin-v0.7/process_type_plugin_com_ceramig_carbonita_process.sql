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
--     PLUGIN: 11402723678639691
--   Manifest End
--   Version:         22.2.0
--   Instance ID:     800172743070494
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/process_type/com_ceramig_carbonita_process
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(11402723678639691)
,p_plugin_type=>'PROCESS TYPE'
,p_name=>'COM.CERAMIG.CARBONITA.PROCESS'
,p_display_name=>'carbonita.process'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_PROC:APEX_APPL_AUTOMATION_ACTIONS:APEX_APPL_TASKDEF_ACTIONS'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'       const_nodejs_url  constant VARCHAR2(250)  :=  ''http://10.1.1.142:8000/'';',
'    const_req_newline  CONSTANT VARCHAR2(50) := chr(13)',
'                                               || chr(10);',
'    const_req_boundary CONSTANT VARCHAR2(50) := ''----FormBoundary7MA4YWxkTrZu0gW'';',
'    const_req_encoding CONSTANT VARCHAR2(250) := ''base64'';',
'    const_v_newline    CONSTANT VARCHAR2(10) := chr(13)',
'                                             || chr(10);',
'    const_v_boundary   CONSTANT VARCHAR2(60) := ''---------------------------30837156019033'';',
'    const_v_end        CONSTANT VARCHAR2(10) := ''--'';',
'    const_v_separator  CONSTANT VARCHAR2(10) := '';'';',
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
'    ',
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
' PROCEDURE carbonita_pkg_generate_report (',
'        p_template_blob     IN BLOB, ',
'        p_template_mimetype IN VARCHAR2 DEFAULT ''application/vnd.openxmlformats-officedocument.wordprocessingml.document'',',
'',
'        p_report_data        IN CLOB, -- json data to send',
'        p_report_name        IN VARCHAR2 DEFAULT ''result'', -- report name',
'        p_report_type        IN VARCHAR2 DEFAULT ''pdf'', -- report type',
'        p_url               IN VARCHAR2 DEFAULT const_nodejs_url,-- nodejs server url where to  POST',
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
' FUNCTION carbonita_plugin_process (',
'        p_process IN apex_plugin.t_process,',
'        p_plugin  IN apex_plugin.t_plugin',
'    ) RETURN apex_plugin.t_process_exec_result IS',
'',
'        l_plg_process_result       apex_plugin.t_process_exec_result;',
'',
'        l_url                      VARCHAR2(255);',
'        l_separator                    VARCHAR2(255);',
'        l_report_name              VARCHAR2(255);',
'        l_report_type              VARCHAR2(255);',
'        l_apex_template_static VARCHAR2(255);',
'        l_plg_template_static_item VARCHAR2(255);',
'        l_apex_query_json          VARCHAR2(4000);',
'',
'        l_plg_ptres_names  VARCHAR2(4000)    ;',
'        l_plg_ptres_names_item  VARCHAR2(4000)    ;',
'        l_plg_ptres_values_item  VARCHAR2(4000)        ;',
'',
'        l_data_clob                CLOB;',
'        l_template_blob            BLOB;',
'        l_template_mimetype        VARCHAR2(255); ',
'        l_out_blob                 BLOB;',
'        l_out_mimetype             VARCHAR2(250);',
'        l_out_filename             VARCHAR2(250);',
'        l_out_size                 NUMBER;',
'',
'        v_file  blob;',
'          v_download      RAW(32767);',
'                  l_offset NUMBER := 1;',
'  l_chunk  NUMBER := 3000;',
'    BEGIN',
'',
'        l_url := p_plugin.attribute_01; --server url',
'        l_separator := p_plugin.attribute_02; --default parameter separator',
'',
'        l_apex_query_json               := p_process.attribute_01;',
'',
'        l_apex_template_static          := p_process.attribute_02;',
'        l_report_name                   := p_process.attribute_03;',
'        l_report_type                   := p_process.attribute_04;',
'',
'        l_plg_ptres_names                   := p_process.attribute_08 ;',
'        l_plg_ptres_names_item              := p_process.attribute_05 ;',
'        l_plg_ptres_values_item             := p_process.attribute_06 ;  ',
'        l_plg_template_static_item          := p_process.attribute_07 ;  ',
'',
'        BEGIN',
'',
'            begin -- get template blob from static',
'',
'                dbms_lob.createtemporary(l_template_blob, TRUE, dbms_lob.session);',
'                carbonita_pkg_get_report_template(',
'                    p_template_static       =>  nvl(v(l_plg_template_static_item),l_apex_template_static),',
'                    p_app_id                =>  v(''APP_ID''),',
'                        out_template_blob       => l_template_blob,',
'                        out_template_mimetype   => l_template_mimetype',
'                );    ',
'            end ;',
'            begin -- get data',
'',
'              ',
'                 l_data_clob := carbonita_pkg_get_data_clob(',
'                                p_query_json        => l_apex_query_json,',
'                                p_parameter_holders => nvl(v(l_plg_ptres_names_item),l_plg_ptres_names),',
'                                p_parameter_values  => v(l_plg_ptres_values_item),',
'                              --  p_parameter_holders => l_plg_ptres_names_item,',
'                              --  p_parameter_values  => l_plg_ptres_values_item,',
'                                p_separator         => nvl(l_separator,'';'')',
'                        );        ',
'              --  begin insert into carbonita_test (data_clob) values (l_data_clob); commit; end;        ',
'            end;',
'            begin -- generate report',
'            dbms_lob.createtemporary(l_out_blob, TRUE, dbms_lob.session);',
'                carbonita_pkg_generate_report(',
'                    p_template_blob     => l_template_blob, ',
'                    --  p_template_mimetype optional without ',
'                    p_report_data        => l_data_clob, ',
'                    p_report_name        => l_report_name, ',
'                    p_report_type        => l_report_type, ',
'                    p_url => l_url,',
'',
'',
'                        out_blob => l_out_blob, ',
'                        out_mimetype => l_out_mimetype, ',
'                        out_filename => l_out_filename, ',
'                        out_size => l_out_size',
'',
'                                          );',
'            end;',
'            begin -- initiate plssql download ',
'               IF 1 = 1 THEN',
'                BEGIN ',
'                  --  l_plg_process_result.success_message := ''hi'';',
'                --   sys.htp.flush; -- ??',
'                 --   dbms_lob.createtemporary(v_file, TRUE, dbms_lob.session);',
'                    /*',
'                    LOOP',
'                        BEGIN',
'                        --sys.dbms_lob.read(l_out_blob, v_download);',
'                        dbms_lob.writeappend(v_file, utl_raw.length(l_out_blob), l_out_blob);',
'                        EXCEPTION      WHEN sys.utl_http.end_of_body THEN     EXIT;',
'                                when others then-- ziada',
'                                    if sqlcode <> -29266 then raise; end if;',
'                        END;',
'                    END LOOP;',
'                    */',
'                    sys.htp.init;',
'',
'                    sys.owa_util.mime_header(l_out_mimetype, false);',
'                    sys.htp.p(''Content-length: ''                            || sys.dbms_lob.getlength(l_out_blob));',
'                    sys.htp.p(''Content-Disposition: attachment; filename="'' || l_report_name || ''"'');',
'',
'                    sys.htp.p(''Cache-Control: no-cache '');  -- tell the browser to cache for one hour, adjust as necessary',
'                    sys.owa_util.http_header_close;',
'',
'                    sys.wpg_docload.download_file(l_out_blob);',
'                    /**LOOP',
'                        EXIT WHEN l_offset > LENGTH(l_out_blob);',
'                        HTP.prn(dbms_lob.SUBSTR(l_out_blob, l_offset, l_chunk));',
'                        l_offset := l_offset + l_chunk;',
'                    END LOOP; */',
'                    apex_application.stop_apex_engine;',
'                   -- dbms_lob.freetemporary(l_out_blob);',
'                  EXCEPTION ',
'                        WHEN apex_application.e_stop_apex_engine THEN     htp.p(''process error'');',
'                        --when others then  message_error(l_sqlerrm => sqlerrm);',
'                        --other then apex_application.stop_apex_engine;',
'                END;',
'               END IF;',
'',
'            end;',
'',
'        END;',
'',
'',
'',
'',
'        RETURN l_plg_process_result;',
'    END carbonita_plugin_process;  ',
'    ',
''))
,p_api_version=>2
,p_execution_function=>'carbonita_plugin_process'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'0.7'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(11601498213090998)
,p_plugin_id=>wwv_flow_imp.id(11402723678639691)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'server_url'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'http://10.1.1.142:80/'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(4002620757087927)
,p_plugin_id=>wwv_flow_imp.id(11402723678639691)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'plugin_separator'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>';'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(11600284889077462)
,p_plugin_id=>wwv_flow_imp.id(11402723678639691)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>100
,p_prompt=>'process_query_json'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_default_value=>'select JSON_ARRAYAGG(json_object(ename,job)) val from emp'
,p_is_translatable=>false
,p_examples=>'select JSON_ARRAYAGG(json_object(ename,job)) val from emp'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(11600501634082260)
,p_plugin_id=>wwv_flow_imp.id(11402723678639691)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>120
,p_prompt=>'template_static'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(11600825803086438)
,p_plugin_id=>wwv_flow_imp.id(11402723678639691)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>140
,p_prompt=>'report_name'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(11601113461087453)
,p_plugin_id=>wwv_flow_imp.id(11402723678639691)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>150
,p_prompt=>'report_type'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(15206697919216936)
,p_plugin_id=>wwv_flow_imp.id(11402723678639691)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>170
,p_prompt=>'query_parameters_item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(15207496382219865)
,p_plugin_id=>wwv_flow_imp.id(11402723678639691)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>180
,p_prompt=>'query_values_item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(31207859857003905)
,p_plugin_id=>wwv_flow_imp.id(11402723678639691)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>130
,p_prompt=>'template_static_item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(4003438276091143)
,p_plugin_id=>wwv_flow_imp.id(11402723678639691)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>160
,p_prompt=>'query_parameters'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
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
