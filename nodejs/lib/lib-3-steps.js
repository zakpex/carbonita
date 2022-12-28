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
        this.result_path = './result0' +'.txt';
        this.result_bin = new Uint8Array(Buffer.from('empty'));
    }

}

let myreport_def = new TheReport();

const add = (function () {
    let counter = 0;
    return function () { counter += 1; return counter }

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

        var newpath = path +'-n-'+ "-f05-binary" ;//+ '.' + 'txt' ; //l_extention;

        fs.readFile(path, 'utf8', function (err, data) {
            console.log(path);
            console.log(newpath);
            console.log(originalFilename);
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
                            myResolve(writepath);
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
    return new Promise(function (myResolve0, myReject0) {

        try {
            async function report_update01(report, fields, files) {
                return new Promise(function (myResolve, myReject) {
                    try {
                        report.data_json = JSON.parse(fields.data_text);
                        report.report_name = fields.report_name || 'result';
                        report.report_type = fields.report_type || "txt";
                        console.log('pasing type'+ fields.report_type );
                        report.mimetype = mime.get_mime(fields.report_type);
                        myResolve(myreport_def);

                    } catch (error) {
                        myReject(error)
                    }



                });
            };
            async function report_update02(report, fields, files) {
                return new Promise(function (myResolve, myReject) {
                    if (fields.req_encoding == 'binary') {
                        
                        report.result_path = './result-' + add() + '.' + fields.report_type;
                        report.template_path = files.template_binary.filepath;
                        myResolve(report);
                    } else { // base64
                        // var l_filename1 = 'file walou' + files.template_binary.originalFilename;
                        convert_base64(files.template_binary.filepath)
                            .then(
                                function (data_new_path) {
                                    // new Promise(function (myResolve, myReject) {
                                    report.template_path = data_new_path;
                                    report.result_path = './result-' + add() + '.' + fields.report_type;

                                    
                                    // remove  the old base64 template 
                                    fs.unlink(files.template_binary.filepath, function (err) {
                                        if (err) {
                                            console.error(err);
                                            console.error("err remove  after convert base64 ");
                                            myReject(err);
                                        } else {
                                            console.log("success remove base 64 template ! " + files.template_binary.filepath);
                                            myResolve(report); // return after remove ?
                                        }
                                    });
                                    if (1 == 1) {

                                    } else {
                                        myReject(error);
                                    }
                                    //  });
                                    //myResolve(myreport_def);
                                },
                                function (error) {
                                    console.log('ERROR convert_base64');
                                    myReject(error); // error converting from base64

                                }
                            );
                    }



                    if (1 == 1) {

                    } else {
                        myReject(report);
                    }

                });
            };
            const re = /(\.)(\S{1,})$/g;
            if (1 == 2) {
         // old parse 


            } else { // test 02
                report_update01(myreport_def, fields, files)
                    .then(
                        function (data) {
                            console.log('--update01');
                            console.log('--update parsing : '+fields.report_type);
                            report_update02(myreport_def, fields, files)
                                .then(
                                    function (data) {
                                        console.log('after update02');
                                        // console.log(data);
                                        myResolve0(data);
                                    },
                                    function (error) {
                                        // console.log('after update02 -error-'); 
                                        myReject0(error);
                                    },

                                );

                        },
                        function (error) { myReject0(error); }
                    )
            }

            //  myResolve(myreport_def);
        } catch (error) {
            myReject0(error)
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
            convertTo: report.report_type//can be docx, txt, ...
            //  convertTo: 'txt'
             , hardRefresh: true
        };
        console.log('inside render path p1' + report.template_path);
        console.log('inside render path p2' + myreport_def.template_path);
        console.log('Report_type '+report.report_type);
        carbone.render(report.template_path, report.data_json, options, (err, data) => {
            if (err) {
                myReject(err)
            } else {
                report.result_bin = data;
                console.log('inside-render1');
                                //myreport_def.result_bin
                                                fs.unlink(report.template_path, function (err) {
                    if (err) { } else {
                        console.log("success remove template  " + report.template_path);
                    }
                });
                myResolve(report);
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
    constructor(path, mimetype,report_name) {
        this.path = path;
        this.mimetype = mimetype;
        this.name = report_name;
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

            var l_result = new TheResult(myreport_def.result_path, myreport_def.mimetype,myreport_def.report_name);
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
            if (1 == 2) { //Will destroyed elsewhere 
                 
                fs.unlink(path_to_destory, function (err) {
                    if (err) {
                        console.error(err);
                        //throw err;
                        myReject(error)
                    } else {
                        console.log("success remove result ! " + path_to_destory);
                      //  myResolve(report)

                    }
                })
            }
            myResolve(report)
        } catch (error) {
            myReject(error)
        }
        var x = 1;
        // var stat = fs.statSync(path);
       
       /* if (1 === 1) {
            myResolve(report);
        } else {
            myReject("-1-error parsing-");
        }
        */
    });
};








module.exports.myPromise01_parse = myPromise01_parse;
module.exports.myPromise02_render = myPromise02_render;
module.exports.myPromise03_write = myPromise03_write;
module.exports.myPromise04_send = myPromise04_send;
module.exports.myPromise04_destroy = myPromise04_destroy;

module.exports.TheReport = TheReport;
module.exports.myreport_def = myreport_def;

