const fs = require('fs');
const carbone = require('carbone');
const Base64 = require('js-base64');
const mime = require("./lib-mimestypes");

class TheReport {
    constructor(template, data, name, type, mimetype) {
        // this.template = template;
        // this.data_json = data;
        this.template_path = template;
        this.data_json = data;
        this.report_name = name;
        this.report_type = type;
        this.mimetype = mimetype;
        this.result_path = './result0.txt';
        this.result_bin = new Uint8Array(Buffer.from('empty'));
    }

}

let myreport_def = new TheReport();

const add = (function () {
    let counter = 0;
    return function () { counter += 1; return 1; /*counter*/ }

})();

async function convert_base64(path, originalFilename) {
    return new Promise(function (myResolve, myReject) {
        //var newpath = path + "-f05-binary";
        const re = /(\.)(\S{1,})$/g;
        //var l_extention = originalFilename.match(re)[0].match(/\w+/g)[0].match(/\w+/g)[0];
       /* var l_extention =originalFilename.match(re);
        var l_extention2 =l_extention[0];
        var l_extention3 =l_extention2.match(/\w+/g);
        
        console.log('extention'+  originalFilename );
        console.log('extention should be'+  l_extention3[0]);*/

        var newpath = path + "-f05-binary" ;//+ '.' + 'txt' ; //l_extention;

        fs.readFile(path, 'utf8', function (err, data) {
            console.log(path);
            console.log(newpath);
            var bin = Base64.atob(data);


            fs.writeFile(newpath, bin, "binary", function (err, writepath) {
                console.log("should we wait for the new file to be generated");
                myResolve(newpath);
                //myResolve(writepath);
                //   unlink the old one
                if (1 == 2) {
                    fs.unlink(path, function (err) {
                        if (err) {
                            console.error(path);
                            console.error(newpath);
                            console.error(err);
                            myReject(err);
                            //--if (err) throw err;
                        } else {
                            console.log("success rename! " + newpath);
                            myResolve(newpath);
                        }
                    });
                }
            });
        });
    });
    //   var binary_template;


    // write binary data from base64

}

async function test(path) {
    return new Promise(function (myResolve, myReject) {
        let x = 0;

        if (x == 0) {
            myResolve("OK");
        } else {
            myReject("Error");
        }
    });
    //   var binary_template;


    // write binary data from base64

}
async function myPromise01_parse(fields, files) {
    return new Promise(function (myResolve, myReject) {

        try {
            async function report_update01(report,fields,files) {
                return new Promise(function (myResolve,myReject){
                    myreport_def.data_json = JSON.parse(fields.data_text);
                    myreport_def.report_name = fields.report_name || 'result';
                    myreport_def.report_type = fields.report_type || "txt";
                    myreport_def.mimetype = mime.get_mime(fields.report_type);
                    if (1==1) {
                        myResolve(report);
                    }else {
                        myReject(report);
                    }

                });
            };
            async function report_update02(report,fields,files) {
                return new Promise(function (myResolve,myReject){
                    
                    
                    if (1==1) {
                        myResolve(report);
                    }else {
                        myReject(report);
                    }

                });
            };
            const re = /(\.)(\S{1,})$/g;
            if (1 == 1) {
                if (fields.req_encoding == 'binary') {

                    myreport_def.template_path = files.template_binary.filepath;


                    myreport_def.data_json = JSON.parse(fields.data_text);
                    myreport_def.report_name = fields.report_name || 'result';
                    myreport_def.report_type = fields.report_type || "txt";
                    myreport_def.mimetype = mime.get_mime(fields.report_type);
                    // console.log('in1'+fields.report_type);
                    // console.log('in2'+mime.get_mime(fields.report_type));
                    myreport_def.result_path = './result-' + add() + '.' + fields.report_type;
                    myResolve(myreport_def);

                } else {// fields.req_encoding == 'base64'
                    var l_filename1 = 'file'+   files.template_binary.originalFilename;
                    convert_base64(files.template_binary.filepath, l_filename1 ).then(
                        function (data) {
                            //  var l_path = 'file' + files.template_binary.originalFilename;
                            myreport_def.template_path = data;
                            // destroy old base64 template 
                            fs.unlink(files.template_binary.filepath, function (err) {
                                if (err) {
                                    console.error(err);
                                    //throw err;

                                } else {
                                    console.log("success remove base 64 template ! " + files.template_binary.filepath);

                                }
                            });

                            //+ '.'
                            // + l_path.match(re)[0].match(/\w+/g)[0].match(/\w+/g)[0];
                            console.log('---' + data);
                            myreport_def.data_json = JSON.parse(fields.data_text);
                            myreport_def.report_name = fields.report_name || 'result';
                            myreport_def.report_type = fields.report_type || "txt";
                            myreport_def.mimetype = mime.get_mime(fields.report_type);
                            // console.log('in1'+fields.report_type);
                            // console.log('in2'+mime.get_mime(fields.report_type));
                            myreport_def.result_path = './result-' + add() + '.' + fields.report_type;
                            myResolve(myreport_def);
                        },
                        function (error) { 
                            console.log('error-parse' + error) ;
                            // console.log('error-path' + path) ;
                            // console.log('error-newpath' + newpath) ;
                            myReject(error);

                    })

                }



            }

            //  myResolve(myreport_def);
        } catch (error) {
            myReject(error)
        }
        /*  if (1 === 1) {
              myResolve(report);
          } else {
              myReject("-1-error parsing-");
          }*/
    })
};

async function myPromise02_render(report) {
    return new Promise(function (myResolve, myReject) {
        //let report = new TheReport();
        var options = {
            convertTo: myreport_def.report_type//can be docx, txt, ...
            //  convertTo: 'txt'
        };

        carbone.render(myreport_def.template_path, myreport_def.data_json, options, (err, data) => {
            if (err) {
                myReject(err)
            } else {
                myreport_def.result_bin = data;
                console.log('inside-render1');

                fs.unlink(myreport_def.template_path, function (err) {
                    if (err) {} else  {
                        console.log("success remove template  " + myreport_def.template_path);
                    }
                });
                myResolve(myreport_def);
            };
        })

        /*if (1 === 1) {
            myResolve(report);
        } else {
            myReject("-1-error parsing-");
        }*/
    })
};

async function myPromise03_write(report) {
    return new Promise(function (myResolve, myReject) {

        fs.writeFile(myreport_def.result_path, myreport_def.result_bin, (err, data) => {
            //report.result_path
            if (err) {
                myReject(err)
            } else {
                myResolve(report);
            }
        }); /*if (1 === 1) {
                myResolve(report);
            } else {
                myReject("-1-error parsing-");
            }*/
    });
};
class TheResult {
    constructor(path, mimetype) {
        this.path = path;
        this.mimetype = mimetype;
    }
}
async function myPromise04_send(res, report) {
    return new Promise(function (myResolve, myReject) {
        // var stat = fs.statSync(path);
        try {
            /*  res.writeHead(200, {
                  'Content-Type': myreport_def.mimetype || 'text/plain' //TODO report.mimetype
                  //, 'Content-Length': stat.size
              });
              var readStream = fs.createReadStream(myreport_def.result_path);
              readStream.pipe(res);
            */

            var l_result = new TheResult(myreport_def.result_path, myreport_def.mimetype);
            console.log('mim' + myreport_def.mimetype);
            if (1 == 2) {
                res.setHeader('Content-Type', 'text/plain');
                res.statusCode = 200;
                //res.writeHead(200, { 'Content-Type': 'text/plain' });
                res.end('hello ');
            }

            myResolve(l_result);
        } catch (error) {

            myReject(error)

        }
        ;
        /*if (1 === 1) {
                myResolve(report);
            } else {
                myReject("-1-error parsing-");
            }*/
    });
};
async function myPromise04_destroy(report) {
    return new Promise(function (myResolve, myReject) {
        try {
            if (1 == 2) {
                fs.unlink(path_to_destory, function (err) {
                    if (err) {
                        console.error(err);
                        //throw err;

                    } else {
                        console.log("success remove! " + path_to_destory);

                    }
                })
            }
            myResolve(report)
        } catch (error) {
            myReject(error)
        }
        var x = 1;
        // var stat = fs.statSync(path);
        if (1 === 1) {
            myResolve(report);
        } else {
            myReject("-1-error parsing-");
        }
    });
};








module.exports.myPromise01_parse = myPromise01_parse;
module.exports.myPromise02_render = myPromise02_render;
module.exports.myPromise03_write = myPromise03_write;
module.exports.myPromise04_send = myPromise04_send;
module.exports.myPromise04_destroy = myPromise04_destroy;

module.exports.TheReport = TheReport;
module.exports.myreport_def = myreport_def;

