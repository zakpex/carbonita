--------------------------------------------------------
--  File created - Thursday-November-24-2022   
--------------------------------------------------------
DROP TABLE "DEV"."CARBONITA_CALLS" cascade constraints;
DROP TABLE "DEV"."CARBONITA_TEST" cascade constraints;
DROP PACKAGE "DEV"."CARBONITA_PKG";
DROP PACKAGE "DEV"."CARBONITA_PLUGIN_PKG";
DROP PACKAGE BODY "DEV"."CARBONITA_PKG";
DROP PACKAGE BODY "DEV"."CARBONITA_PLUGIN_PKG";
--------------------------------------------------------
--  DDL for Table CARBONITA_CALLS
--------------------------------------------------------

  CREATE TABLE "DEV"."CARBONITA_CALLS" 
   (	"ID" NUMBER DEFAULT ON NULL to_number(sys_guid(), 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'), 
	"REQ_DATA_CLOB" CLOB, 
	"REQ_TEMPLATE_BLOB" BLOB, 
	"CALL_PROCESS" VARCHAR2(4000 CHAR), 
	"CARBONITA_URL" VARCHAR2(4000 CHAR), 
	"CREATED" DATE, 
	"CREATED_BY" VARCHAR2(255 CHAR), 
	"UPDATED" DATE, 
	"UPDATED_BY" VARCHAR2(255 CHAR), 
	"THE_QUERY_JSON" VARCHAR2(4000 BYTE), 
	"THE_QUERY" VARCHAR2(4000 BYTE), 
	"TAG" VARCHAR2(200 BYTE)
   ) ;
--------------------------------------------------------
--  DDL for Table CARBONITA_TEST
--------------------------------------------------------

  CREATE TABLE "DEV"."CARBONITA_TEST" 
   (	"COLUMN1" VARCHAR2(20 BYTE), 
	"FILE_BLOB" BLOB, 
	"DATA_CLOB" CLOB, 
	"RESULT_BLOB" BLOB, 
	"RESULT_MIMTYPE" VARCHAR2(200 BYTE), 
	"TEST_CLOB" CLOB
   )   ;
--------------------------------------------------------
--  DDL for Trigger CARBONITA_CALLS_BIU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV"."CARBONITA_CALLS_BIU" 
    before insert or update 
    on carbonita_calls
    for each row
begin
    if inserting then
        :new.created := sysdate;
        :new.created_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
    end if;
    :new.updated := sysdate;
    :new.updated_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
end carbonita_calls_biu;

/
ALTER TRIGGER "DEV"."CARBONITA_CALLS_BIU" ENABLE;
--------------------------------------------------------
--  DDL for Trigger CARBONITA_CALLS_BIU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV"."CARBONITA_CALLS_BIU" 
    before insert or update 
    on carbonita_calls
    for each row
begin
    if inserting then
        :new.created := sysdate;
        :new.created_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
    end if;
    :new.updated := sysdate;
    :new.updated_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
end carbonita_calls_biu;

/
ALTER TRIGGER "DEV"."CARBONITA_CALLS_BIU" ENABLE;
--------------------------------------------------------
--  DDL for Package CARBONITA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV"."CARBONITA_PKG" AS 

    function get_data_clob (
        p_query_json in varchar2 default q'#select JSON_ARRAYAGG(json_object(ename,job)) val from emp#'
                            ) return clob;
    
    procedure get_report_template(
        p_template_static   in varchar2,
        p_app_id            in number   DEFAULT v('APP_ID'), 
        
        out_template_blob     out blob,
        out_template_mimetype out varchar2
                            ) ;
     PROCEDURE generate_report (
        p_template_blob     IN BLOB, 
        p_template_mimetype IN VARCHAR2 DEFAULT 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        
        p_report_data        IN CLOB, -- json data to send
        p_report_name        IN VARCHAR2 DEFAULT 'result', -- report name
        p_report_type        IN VARCHAR2 DEFAULT 'pdf', -- report type
        p_url               IN VARCHAR2 DEFAULT carbonita_plugin_pkg.const_nodejs_url,-- nodejs server url where to  POST

        out_blob            OUT BLOB,-- generated report as blob
        out_mimetype        OUT VARCHAR2,
        out_filename        OUT VARCHAR2,
        out_size            OUT NUMBER --??             
    );                          
END CARBONITA_PKG;

/
--------------------------------------------------------
--  DDL for Package CARBONITA_PLUGIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV"."CARBONITA_PLUGIN_PKG" as 


    const_nodejs_url  constant VARCHAR2(250)  :=  'http://10.1.1.142:8000/';





  ------------------------------------------------------------------------------------------------------------------

  function plugin_da_render (
    p_dynamic_action in apex_plugin.t_dynamic_action,
    p_plugin         in apex_plugin.t_plugin )
    return apex_plugin.t_dynamic_action_render_result;

  function plugin_region_render(
    p_region              in apex_plugin.t_region,
    p_plugin              in apex_plugin.t_plugin,
    p_is_printer_friendly in boolean )
    return apex_plugin.t_region_render_result   ;

  function plugin_region_ajax (
    p_region in apex_plugin.t_region,
    p_plugin in apex_plugin.t_plugin )
    return apex_plugin.t_region_ajax_result;  

  function plugin_da_ajax (
    p_dynamic_action in apex_plugin.t_dynamic_action,
    p_plugin         in apex_plugin.t_plugin )
    return apex_plugin.t_dynamic_action_ajax_result ; 

  function plugin_process (
    p_process in apex_plugin.t_process,
    p_plugin  in apex_plugin.t_plugin )
    return apex_plugin.t_process_exec_result;
------------------------------------------------------------------------------------------------------------------


  ------------------------------------------------------------------------------------------------------------------

  PROCEDURE apex_download_file ( -- just download blob as file
        p_blob      IN OUT  BLOB,
        p_filename  IN      VARCHAR2,
        p_mimetype  IN      VARCHAR2
                -- apex_application.stop_apex_engine;
                                );             

end CARBONITA_plugin_pkg;

/
--------------------------------------------------------
--  DDL for Package Body CARBONITA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV"."CARBONITA_PKG" AS

    const_req_newline  CONSTANT VARCHAR2(50) := chr(13)
                                               || chr(10);
    const_req_boundary CONSTANT VARCHAR2(50) := '----FormBoundary7MA4YWxkTrZu0gW';
    const_req_encoding CONSTANT VARCHAR2(250) := 'base64';
    const_v_newline    CONSTANT VARCHAR2(10) := chr(13)
                                             || chr(10);
    const_v_boundary   CONSTANT VARCHAR2(60) := '---------------------------30837156019033';
    const_v_end        CONSTANT VARCHAR2(10) := '--';

    ---------------------------------------------------
    -- PRIVATE ---
            
          FUNCTION build_req_body (
                req_template_blob     IN BLOB,
                req_template_mimetype IN VARCHAR2 DEFAULT 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                req_data        IN CLOB,
                         --   req_data_charset   in  varchar2 ,  -- ISO-8859-1 to  WE8ISO8859P1     
                req_reporttype        IN VARCHAR2,
                req_encoding          IN VARCHAR2, -- template encoding binary or clobbase64
                req_reportname        IN VARCHAR2
        ) RETURN CLOB AS

            l_req_charset     VARCHAR2(250);
            l_db_charset     VARCHAR2(250);
            l_req_body_return CLOB;
            l_data_clob       CLOB;
            l_str_part        VARCHAR2(32767);
            l_length          INTEGER;
            l_start           INTEGER := 1;
            l_recsize         CONSTANT INTEGER := 4000;
        BEGIN
        -- TODO optimze pretify 
            utl_http.get_body_charset(charset => l_req_charset); --WE8ISO8859P1: ISO 8859-1
            select property_value into l_db_charset from database_properties where property_name = 'NLS_CHARACTERSET';
            
            
            dbms_lob.createtemporary(l_data_clob, false);
            IF 1 = 1 THEN
                BEGIN -- convert report_date 
                 -- Convert  data( from the query ) from charset AL32UTF8 (db charset) to WE8ISO8859P1 (utl http charset)
                 -- ... we convert by parts to avoid 32K limit 
                 -- ... initialy was l_data_clob :=convert( dbms_lob.substr(req_data,dbms_lob.getlength(req_data)),'AL32UTF8', 'WE8ISO8859P1'); -- size problem

                    l_length := dbms_lob.getlength(req_data);
                    dbms_lob.createtemporary(l_data_clob, false);
                    WHILE l_start <= l_length LOOP
                        l_str_part := dbms_lob.substr(req_data, l_recsize, l_start);
                        if l_req_charset = 'ISO-8859-1' then 
                            dbms_lob.append(l_data_clob, convert(l_str_part, 'AL32UTF8', 'WE8ISO8859P1'));
                        else
                            dbms_lob.append(l_data_clob, l_str_part );
                        end if;
                        --dbms_lob.append(l_data_clob, convert(l_str_part, l_db_charset,l_req_charset)); -- fail ?
                        
                        l_start := l_start + l_recsize;
                    END LOOP;

                END;
            END IF;

            dbms_lob.createtemporary(l_req_body_return, false); -- how useful ?
            l_req_body_return := const_req_newline
                                 || '--'
                                 || const_req_boundary
                                 || const_req_newline
                                 || 'Content-Disposition: form-data; name="template_binary"; filename="template_binary"'
                                 || const_req_newline
                                 || 'Content-Type: '
                                 || req_template_mimetype-- 'application/any.recognized.libreoffice'
                                 || const_req_newline
                                 || const_req_newline
                                 || apex_web_service.blob2clobbase64(req_template_blob)
                                 || const_req_newline
                                 || '--'
                                 || const_req_boundary
                                 || const_req_newline
                      /*
                      || 'Content-Disposition: form-data; name="filename"'
                      || const_req_newline
                      || const_req_newline
                      || 'filetemplate.docx'
                      || const_req_newline || '--' || const_req_boundary || const_req_newline

                      || 'Content-Disposition: form-data; name="MAX_FILE_SIZE"'
                      || const_req_newline
                      || const_req_newline
                      || '4000000'
                      || const_req_newline || '--' || const_req_boundary || const_req_newline
                      */
                                 || 'Content-Disposition: form-data; name="report_type"'
                                 || const_req_newline
                                 || const_req_newline
                                 || req_reporttype
                                 || const_req_newline
                                 || '--'
                                 || const_req_boundary
                                 || const_req_newline
                                 || 'Content-Disposition: form-data; name="req_encoding"'
                                 || const_req_newline
                                 || const_req_newline
                                 || req_encoding
                                 || const_req_newline
                                 || '--'
                                 || const_req_boundary
                                 || const_req_newline
                                 || 'Content-Disposition: form-data; name="report_name"'
                                 || const_req_newline
                                 || const_req_newline
                                 || req_reportname
                                 || const_req_newline
                                 || '--'
                                 || const_req_boundary
                                 || const_req_newline
                                 || 'Content-Disposition: form-data; name="data_text"'
                                 || const_req_newline
                                 || const_req_newline
                                 ||
                CASE
                    WHEN 1 = 1 OR l_req_charset = 'ISO 8859-1' -- is the case by default
                     THEN
                        l_data_clob
                                --req_data
                            --convert(
                              --  req_data,
                                --dbms_lob.substr(req_data, dbms_lob.getlength(req_data)), 
                                    --'AL32UTF8', 'WE8ISO8859P1')
                    ELSE l_data_clob -- req_data
                END
                                 || const_req_newline
                                 || '--'
                                 || const_req_boundary
                                 || '--';

            dbms_lob.freetemporary(l_data_clob);
            RETURN l_req_body_return;
        END build_req_body;

        PROCEDURE post_req (
            req_body     IN out CLOB,
            p_url        IN VARCHAR2 ,
            out_blob     OUT BLOB,
            out_mimetype OUT VARCHAR2,
            out_filename OUT VARCHAR2,
            out_size     OUT NUMBER --?? 
        ) AS

            l_request_body_length   NUMBER;
            l_http_request          utl_http.req;
            l_http_response         utl_http.resp;
            l_response_header_name  VARCHAR2(256);
            l_response_header_value VARCHAR2(2000);

                 --l_response_blob blob; -- output 
            l_offset                NUMBER := 1;
            l_amount                NUMBER := 2000;
            l_buffer                VARCHAR2(4000);
            l_raw                   RAW(32767);
            
        BEGIN
            l_request_body_length := dbms_lob.getlength(req_body);
            utl_http.set_transfer_timeout(200);
            l_http_request := utl_http.begin_request(url => p_url, method => 'POST', http_version => 'HTTP/1.1');

            utl_http.set_header(l_http_request, 'Content-Type', 'multipart/form-data; boundary="'
                                                                || const_req_boundary
                                                                || '"');
            utl_http.set_header(l_http_request, 'Content-Length', l_request_body_length);
            WHILE l_offset < l_request_body_length LOOP
                dbms_lob.read(req_body, l_amount, l_offset, l_buffer);
                utl_http.write_text(l_http_request, l_buffer);
                l_offset := l_offset + l_amount;
            END LOOP;

            l_http_response := utl_http.get_response(l_http_request);
            BEGIN
                FOR i IN 1..utl_http.get_header_count(l_http_response) LOOP
                    utl_http.get_header(l_http_response, i, l_response_header_name, l_response_header_value);
                    IF l_response_header_name = 'Content-Disposition' THEN
                        out_filename := regexp_substr(l_response_header_value, '(filename=)([^,]+)', 1, 1, 'i',
                                                     2);
                    END IF;

                    IF l_response_header_name = 'Content-Type' THEN
                        out_mimetype := l_response_header_value;
                    END IF;
                    IF l_response_header_name = 'Content-Length' THEN
                        out_size := l_response_header_value;
                    END IF;
                END LOOP;

                dbms_lob.createtemporary(out_blob, false);--utl_http.read_text(l_http_response, l_response_body, 32767);

                BEGIN
                    LOOP
                        utl_http.read_raw(l_http_response, l_raw, 32766);
                        dbms_lob.writeappend(out_blob, utl_raw.length(l_raw), l_raw);
                    END LOOP;
                EXCEPTION
                    WHEN utl_http.end_of_body THEN
                        begin
                        utl_http.end_response(l_http_response);
                        dbms_lob.freetemporary(out_blob);
                        end;
                END;
                        --dbms_lob.freetemporary(out_blob);  -- ??
                        

            EXCEPTION
                                --WHEN UTL_HTTP.end_of_body THEN
                                --       UTL_HTTP.end_response(l_http_response);
                                --       UTL_HTTP.end_request(l_http_request);
                WHEN OTHERS THEN
                    IF l_http_request.private_hndl IS NOT NULL THEN
                        utl_http.end_request(l_http_request);
                        dbms_lob.freetemporary(out_blob); 
                        dbms_lob.freetemporary(req_body); 
                    END IF;
                    IF l_http_response.private_hndl IS NOT NULL THEN
                        utl_http.end_response(l_http_response);
                        dbms_lob.freetemporary(out_blob); 
                        dbms_lob.freetemporary(req_body); 
                    END IF;
                    RAISE;
            END;

        END post_req;
        
    -- PRIVATE -end 
    ---------------------------------------------------
    
    FUNCTION get_data_clob (
        p_query_json IN VARCHAR2 DEFAULT q'#select JSON_ARRAYAGG(json_object(ename,job)) val from emp#'
    ) RETURN CLOB AS
        l_return_clob  CLOB;
        rc             SYS_REFCURSOR;
         
    BEGIN
 
        IF 1 = 1 THEN -- using  fetch
            BEGIN -- using  fetch

                OPEN rc FOR p_query_json;

                FETCH rc INTO l_return_clob;
                CLOSE rc;
            END;
        END IF;

     

        RETURN l_return_clob;
    END get_data_clob;
    
    procedure get_report_template(
        p_template_static   in varchar2,
        p_app_id            in number DEFAULT v('APP_ID'), 
        
        out_template_blob     out blob,
        out_template_mimetype out varchar2
                            ) as 
    begin
    -- TODO: MIME_TYPE  FILE_CHARSET  
        begin
            SELECT  blob_content,  
                    mime_type
                INTO out_template_blob, 
                     out_template_mimetype
        FROM apex_application_files
        WHERE   file_type = 'STATIC_FILE'
            AND flow_id = p_app_id
            AND filename = p_template_static;
            
        exception when no_data_found then null;
        end;
        
    end get_report_template;

    PROCEDURE generate_report (
        p_template_blob     IN BLOB, 
        p_template_mimetype IN VARCHAR2 DEFAULT 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        
        p_report_data        IN CLOB, -- json data to send
        p_report_name        IN VARCHAR2 DEFAULT 'result', -- report name
        p_report_type        IN VARCHAR2 DEFAULT 'pdf', -- report type
        p_url               IN VARCHAR2 DEFAULT carbonita_plugin_pkg.const_nodejs_url,-- nodejs server url where to  POST

        out_blob            OUT BLOB,-- generated report as blob
        out_mimetype        OUT VARCHAR2,
        out_filename        OUT VARCHAR2,
        out_size            OUT NUMBER --??             
    ) as
        l_req_body CLOB;

    begin

            BEGIN -- build request body
                l_req_body :=   build_req_body(
                                    req_encoding            => const_req_encoding, 
                                    
                                    req_template_blob       => p_template_blob, 
                                    req_template_mimetype   => p_template_mimetype,--  ?? 
                                    
                                    req_data          => p_report_data,
                                    req_reportname => p_report_name,
                                    req_reporttype => p_report_type
                                );
            EXCEPTION WHEN OTHERS THEN begin
                    NULL;
                    end;
            END;

        BEGIN -- post request and retrieve filename                     
                --old version before 2/12/2020
            post_req(
                        req_body => l_req_body, 
                        p_url => p_url, 
                            out_blob => out_blob, 
                            out_mimetype => out_mimetype, 
                            out_filename => out_filename,
                            out_size => out_size
                    );

            NULL;
            BEGIN
                NULL;
            END;
        EXCEPTION  WHEN OTHERS THEN
                BEGIN
                    ---insert into tmp1 (n,d, col1)values (1.2 , sysdate, dbms_lob.getlength(l_req_body)); commit;
                    apex_json.open_object;
                    apex_json.write(sqlerrm);
                    apex_json.close_object;
                    htp.p('wrong');
                    htp.p(sqlerrm);
                    htp.p(p_report_data);
                END;
        END;
     
        
        
    end generate_report; 
END carbonita_pkg;

/
--------------------------------------------------------
--  DDL for Package Body CARBONITA_PLUGIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV"."CARBONITA_PLUGIN_PKG" AS

    const_req_newline  CONSTANT VARCHAR2(50) := chr(13)
                                               || chr(10);
    const_req_boundary CONSTANT VARCHAR2(50) := '----FormBoundary7MA4YWxkTrZu0gW';
    const_req_encoding CONSTANT VARCHAR2(250) := 'base64';
    const_v_newline    CONSTANT VARCHAR2(10) := chr(13)
                                             || chr(10);
    const_v_boundary   CONSTANT VARCHAR2(60) := '---------------------------30837156019033';
    const_v_end        CONSTANT VARCHAR2(10) := '--';

 -- TODO  use utl_http_multipart
 /*
   v_resp := utl_http.get_response(v_req);
	if(v_resp.status_code <> UTL_HTTP.HTTP_OK) then

 */

    TYPE req_part IS RECORD (
        ds_header VARCHAR2(2048),
        ds_value  VARCHAR2(1024),
        ds_blob   BFILE
    );
    TYPE req_parts IS
        TABLE OF req_part;
    
    --refactored procedure
    procedure message_error(l_data_clob IN CLOB default null, l_sqlerrm in varchar2 default null) is
    begin
        apex_json.open_object;
                        apex_json.write('status', 'error');
                        apex_json.write('message', l_sqlerrm);
                        apex_json.write('message', l_data_clob);
                        apex_json.close_object;
                    
    end message_error;    
-----------------------------------------------------------------------------------------------------------------
    FUNCTION plugin_region_render (
        p_region              IN apex_plugin.t_region,
        p_plugin              IN apex_plugin.t_plugin,
        p_is_printer_friendly IN BOOLEAN
    ) RETURN apex_plugin.t_region_render_result AS
    BEGIN
        RETURN NULL;
    END plugin_region_render;

    FUNCTION plugin_region_ajax (
        p_region IN apex_plugin.t_region,
        p_plugin IN apex_plugin.t_plugin
    ) RETURN apex_plugin.t_region_ajax_result AS
    BEGIN
        RETURN NULL;
    END plugin_region_ajax;

    FUNCTION plugin_da_render (
        p_dynamic_action IN apex_plugin.t_dynamic_action,
        p_plugin         IN apex_plugin.t_plugin
    ) RETURN apex_plugin.t_dynamic_action_render_result AS

        l_da_render_result           apex_plugin.t_dynamic_action_render_result;
        
        l_server_url       VARCHAR2(4000) := p_plugin.attribute_01;
        
        l_data_json_query  VARCHAR2(4000) := p_dynamic_action.attribute_01;
        
        l_templatefilename VARCHAR2(4000) := p_dynamic_action.attribute_02; -- template_filename -- text
          --  v(p_dynamic_action.attribute_05); --select static template -- item containt filename
            
        l_report_type      VARCHAR2(4000) := p_dynamic_action.attribute_03;
        l_report_name      VARCHAR2(4000) := p_dynamic_action.attribute_04;
        
        l_templatefilename_as_item  VARCHAR2(4000)  := p_dynamic_action.attribute_05;
        l_reporttype_as_item  VARCHAR2(4000)        := p_dynamic_action.attribute_06;

    BEGIN
          
        apex_plugin_util.debug_dynamic_action(p_plugin => p_plugin, p_dynamic_action => p_dynamic_action);

        apex_javascript.add_library(p_name => 'FileSaver', p_directory => p_plugin.file_prefix, p_check_to_add_minified => true);
        apex_javascript.add_library(p_name => 'carbonita', p_directory => p_plugin.file_prefix, p_check_to_add_minified => true);    

        NULL;
        l_da_render_result.javascript_function := 'carbonita_js.dothejob';
        l_da_render_result.ajax_identifier := apex_plugin.get_ajax_identifier; 

		--L_RESULT.ATTRIBUTE_01 := l_server_url;--'not your business'; --
        --L_RESULT.ATTRIBUTE_05 := l_data_json_query;
        
        l_da_render_result.attribute_01 := l_templatefilename  ;
        l_da_render_result.attribute_02 := l_report_type      ;
        l_da_render_result.attribute_03 := l_report_name;
        l_da_render_result.attribute_04 :=  l_templatefilename_as_item; -- item not available to plsql but is for js
        l_da_render_result.attribute_05 :=  l_reporttype_as_item;-- item not available to plsql but is for js
        
        
        RETURN l_da_render_result;
    END plugin_da_render;

    FUNCTION plugin_da_ajax (
        p_dynamic_action IN apex_plugin.t_dynamic_action,
        p_plugin         IN apex_plugin.t_plugin
    ) RETURN apex_plugin.t_dynamic_action_ajax_result AS 

 -- plugin attributes
        l_da_ajax_result               apex_plugin.t_dynamic_action_ajax_result;
  -- other vars


        l_plg_server_url        VARCHAR2(250)    := p_plugin.attribute_01; --safer than apex_application.g_x01;

        l_js_data_json_query   VARCHAR2(4000)   := p_dynamic_action.attribute_01; --safer than apex_application.g_x05;

        l_plg_template_filename VARCHAR2(250)   := apex_application.g_x01; -- TO check context
        l_plg_report_type       VARCHAR2(250)   := apex_application.g_x02;-- TO check context
        l_plg_report_name       VARCHAR2(250)   := apex_application.g_x03;-- TO check context
   --   l_plg_template_item  VARCHAR2(250)      := apex_application.g_x04;-- TO check context
    --   replace in js l_plg_reporttype_item  VARCHAR2(250)    := apex_application.g_x05;-- TO check context

        l_template_blob        BLOB;
        l_template_mimetype    VARCHAR2(250);
        l_data_clob            CLOB;
        
        l_generated_filename   VARCHAR2(255);
        l_generated_mimetype   VARCHAR2(255);
        l_generated_blob       BLOB;
        l_generated_size       NUMBER;


  --
    BEGIN
        BEGIN -- prepare  template
            carbonita_pkg.get_report_template(
                    p_template_static =>  l_plg_template_filename,
                    p_app_id => v('APP_ID'), 
                    out_template_blob => l_template_blob, 
                    out_template_mimetype => l_template_mimetype
                    );
            EXCEPTION WHEN OTHERS THEN  message_error(l_plg_template_filename,sqlerrm);           
        end;            
        begin -- prepare data    

                l_data_clob := carbonita_pkg.get_data_clob(
                                p_query_json => l_js_data_json_query
                        );
            EXCEPTION WHEN OTHERS THEN begin message_error(l_js_data_json_query,sqlerrm); end;
        END;

        BEGIN -- generate report
                carbonita_pkg.generate_report(
                        p_url => l_plg_server_url, --const_nodejs_url,--nvl(,),
                        p_template_blob => l_template_blob, 
                        p_template_mimetype => l_template_mimetype, 
                        p_report_data => l_data_clob, 
                        p_report_name => l_plg_report_name , --'plugin11', --l_reportname,
                        p_report_type => l_plg_report_type,
                            out_blob => l_generated_blob, 
                            out_mimetype => l_generated_mimetype,
                            out_filename => l_generated_filename, 
                            out_size => l_generated_size);
         --insert into tmp2 (d,dataclob,templateblob) values(sysdate, l_data_clob,l_generated_blob);commit;
            EXCEPTION WHEN OTHERS THEN message_error(l_data_clob,sqlerrm);
        END;


        BEGIN -- ???option 1 download from plsql option 2 download from js 
              -- TOCHECK  
            IF 1 = 2 THEN
                BEGIN     -- if the download apex
                    sys.htp.flush;
                    sys.htp.init;
                    sys.owa_util.mime_header(l_generated_mimetype, false);
                    sys.htp.p('Content-length: '
                              || sys.dbms_lob.getlength(l_generated_blob));

                    sys.htp.p('Content-Disposition: attachment; filename="'
                              || l_generated_filename
                              || '"');
                    sys.htp.p('Cache-Control: no-cache ');  -- tell the browser to cache for one hour, adjust as necessary
                    sys.owa_util.http_header_close;
                    sys.wpg_docload.download_file(l_generated_blob);
                    apex_application.stop_apex_engine;
                  --  dbms_lob.freetemporary(l_generated_blob);
                EXCEPTION -- when other then apex_application.stop_apex_engine;
                    WHEN apex_application.e_stop_apex_engine THEN
                        htp.p('process error');
                END;

            ELSE
                BEGIN -- use filesaver from js
                    apex_json.initialize_output(p_http_header => true);
                    apex_json.flush;
                    apex_json.open_object;
                    apex_json.write('status', 'success');
                    apex_json.write('download', 'js');
                    apex_json.open_object('reportgenerated');
                    apex_json.write('mimetype', l_generated_mimetype);
                    apex_json.write('filename', l_generated_filename);
                    apex_json.write('base64',--  'SGVsbG8gV29ybGQ='); 
                    apex_web_service.blob2clobbase64(l_generated_blob));
                    apex_json.close_object;
                    apex_json.close_object;
                END;
            END IF;
        END;

        RETURN l_da_ajax_result;
    END plugin_da_ajax; 
  -------------------------------------------------------------------------------- 
    FUNCTION plugin_process (
        p_process IN apex_plugin.t_process,
        p_plugin  IN apex_plugin.t_plugin
    ) RETURN apex_plugin.t_process_exec_result IS

        l_plg_process_result       apex_plugin.t_process_exec_result;
        
        l_url                      VARCHAR2(255);
        l_report_name              VARCHAR2(255);
        l_report_type              VARCHAR2(255);
        l_apex_template_static VARCHAR2(255);
        l_apex_query_json          VARCHAR2(4000);
        
        l_data_clob                CLOB;
        l_template_blob            BLOB;
        l_template_mimetype        VARCHAR2(255); 
        l_out_blob                 BLOB;
        l_out_mimetype             VARCHAR2(250);
        l_out_filename             VARCHAR2(250);
        l_out_size                 NUMBER;
        
        v_file  blob;
          v_download      RAW(32767);
                  l_offset NUMBER := 1;
  l_chunk  NUMBER := 3000;
    BEGIN
        
        l_url := p_plugin.attribute_01; --server url

       
        l_apex_query_json               := p_process.attribute_01;
        l_apex_template_static          := p_process.attribute_02;
        l_report_name                   := p_process.attribute_03;
        l_report_type                   := p_process.attribute_04;
          
   
        BEGIN
            
            begin -- get template blob from static
                
                dbms_lob.createtemporary(l_template_blob, TRUE, dbms_lob.session);
                carbonita_pkg.get_report_template(
                    p_template_static       =>  l_apex_template_static,
                    p_app_id                =>  v('APP_ID'),
                        out_template_blob       => l_template_blob,
                        out_template_mimetype   => l_template_mimetype
                );    
            end ;
            begin -- get data
                l_data_clob := carbonita_pkg.get_data_clob(
                                p_query_json => l_apex_query_json
                            );
            end;
            begin -- generate report
            dbms_lob.createtemporary(l_out_blob, TRUE, dbms_lob.session);
                carbonita_pkg.generate_report(
                    p_template_blob     => l_template_blob, 
                    --  p_template_mimetype optional without 
                    p_report_data        => l_data_clob, 
                    p_report_name        => l_report_name, 
                    p_report_type        => l_report_type, 
                    p_url => l_url,
                    
                    
                        out_blob => l_out_blob, 
                        out_mimetype => l_out_mimetype, 
                        out_filename => l_out_filename, 
                        out_size => l_out_size

                                          );
            end;
            begin -- initiate plssql download 
               IF 1 = 1 THEN
                BEGIN 
                  --  l_plg_process_result.success_message := 'hi';
                --   sys.htp.flush; -- ??
                 --   dbms_lob.createtemporary(v_file, TRUE, dbms_lob.session);
                    /*
                    LOOP
                        BEGIN
                        --sys.dbms_lob.read(l_out_blob, v_download);
                        dbms_lob.writeappend(v_file, utl_raw.length(l_out_blob), l_out_blob);
                        EXCEPTION      WHEN sys.utl_http.end_of_body THEN     EXIT;
                                when others then-- ziada
                                    if sqlcode <> -29266 then raise; end if;
                        END;
                    END LOOP;
                    */
                    sys.htp.init;
                    
                    sys.owa_util.mime_header(l_out_mimetype, false);
                    sys.htp.p('Content-length: '                            || sys.dbms_lob.getlength(l_out_blob));
                    sys.htp.p('Content-Disposition: attachment; filename="' || l_out_filename || '"');
                   
                    sys.htp.p('Cache-Control: no-cache ');  -- tell the browser to cache for one hour, adjust as necessary
                    sys.owa_util.http_header_close;
                    
                    sys.wpg_docload.download_file(l_out_blob);
                    /**LOOP
                        EXIT WHEN l_offset > LENGTH(l_out_blob);
                        HTP.prn(dbms_lob.SUBSTR(l_out_blob, l_offset, l_chunk));
                        l_offset := l_offset + l_chunk;
                    END LOOP; */
                    apex_application.stop_apex_engine;
                   -- dbms_lob.freetemporary(l_out_blob);
                  EXCEPTION 
                        WHEN apex_application.e_stop_apex_engine THEN     htp.p('process error');
                        --when others then  message_error(l_sqlerrm => sqlerrm);
                        --other then apex_application.stop_apex_engine;
                END;
               END IF;

            end;
        
        END;

     
        

        RETURN l_plg_process_result;
    END plugin_process;  
------------------------------------------------------------------------------------------------------------------
   PROCEDURE apex_download_file ( -- just download blob as file
        p_blob     IN OUT BLOB,
        p_filename IN VARCHAR2,
        p_mimetype IN VARCHAR2
                -- apex_application.stop_apex_engine;
    ) AS
    BEGIN
        sys.htp.init;
        sys.owa_util.mime_header(p_mimetype, false);
        sys.htp.p('Content-length: '
                  || sys.dbms_lob.getlength(p_blob));

        sys.htp.p('Content-Disposition: attachment; filename="'
                  || p_filename
                  || '"');
        sys.htp.p('Cache-Control: no-cache ');  -- tell the browser to cache for one hour, adjust as necessary
        sys.owa_util.http_header_close;
        sys.wpg_docload.download_file(p_blob);
       -- apex_application.stop_apex_engine;

    END apex_download_file;

END CARBONITA_plugin_pkg;

/
