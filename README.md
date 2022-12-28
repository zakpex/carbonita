# carbonita
pdf  generator for oracle apex #orclAPEX based on carbone, 

Based on [Carbone](https://carbone.io)  , Carbonita use template to generate reports from queries or Interactive report in apex.
The generated reports can be PDF, DOCX, or XLSX.

## Description
carbonita generate pdf, docx, xlsx report whithin apex application 
This application use nodejs server side rendering , which use libreoffice.

### installation 
#### Requirements
- Oracle APEX 
- NodeJS
- Libreoffice
- Carbone on nodejs


#### Steps
##### 1. install node js 
##### 2. install libreoffice on the nodejs server
##### 3. install carbonita package on node js
##### 4. install application on apex 
##### 5. Allow access from apex to the nodejs server 

##  Knowns Issues
#### PGA 
"Incident 134859 created, dump file: /opt/oracle/diag/rdbms/xe/XE/incident/incdir_134859/XE_ora_4487_i134859.trc
ORA-04036: PGA memory used by the instance exceeds PGA_AGGREGATE_LIMIT"
#### bidirectionnal loop 
- Two dimensional loop (pivot unknow number of rows may not show correctly)
- headers in bidirectionnal table may not show correcly.

## TODO
- [ ] https
- [x] plugin da
- [x] plugin process
- [x] plugin report
- [x] nodeserver  as service
- [ ] parameters
- [x] delete template, base64, generated report after response 
- [ ] template 0 from report/query
- [ ] data from context IR 
- [ ] Oauth / security to access
- [ ] Service as REST
- [ ] Log
- [ ] check RTL template (charset problem)

## References & Credits
- [Carbone] https://carbone.io, 
- [LibreOffice](https://www.libreoffice.org/)
- [AmandaDocxPrinter](https://github.com/aldocano29/AmandaDocxPrinter)
- [docxtemplater](https://github.com/open-xml-templating/docxtemplater).
- [Creating a REST API with Node.js and Oracle Database](https://jsao.io/2018/03/creating-a-rest-api-with-node-js-and-oracle-database/)
- [Uploading and Downloading Files with Node.js and Oracle Database](https://jsao.io/2019/06/uploading-and-downloading-files-with-node-js-and-oracle-database)

