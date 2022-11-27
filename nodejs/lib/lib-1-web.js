
const formidable = require("formidable");
const fs = require('fs')
const carbonita = require("./lib-2-job.js");

async function c_get(req, res, next) {
    try {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end('<h1>Hello, world.</h1>');
    } catch (err) {
        next(err);
    }
}



/*
res.format({
  'text/plain': function () {res.send('hey') },
  'text/html': function () {res.send('<p>hey</p>') },
  'application/json': function () {res.send({ message: 'hey' }) },
  default: function () {
    // log the request and respond with 406
    res.status(406).send('Not Acceptable')
  }
})*/
async function c_post(req, res, next) {
    try {
        // res.end('<h1>Hello, world.</h1>');
        const form = new formidable.IncomingForm({
            multiples: true
        });

        form.parse(req, function (err, fields, files) {
            if (err) {
                return res.status(400).json({ error: err.message });
            } {
                // OLD job_result = new carbonita.TheResult();
                // OLD //var filePath = 'C:\\Users\\hachemi.z\\AppData\\Local\\Temp\\dd3da1f184154e84bc6d5c100';
                // OLD //var stat = fs.statSync(filePath);

                // OLD //job_result =  carbonita.job(fields, files, res, next);

                // CARBONITA
                carbonita.job(fields, files, res, next)
                    .then(function (data) {
                        // //// 
                        // res.writeHead(200, { 'Content-Type': data.mimetype || 'text/plain' });
                        // var readStream = fs.createReadStream(data.path);
                        // readStream.pipe(res);

                        // ///--
                        async function send_report() {
                            return new Promise(function (myResolve, myReject) {
                                try {
                                    res.writeHead(200, { 'Content-Type': data.mimetype || 'text/plain' });
                                    var readStream = fs.createReadStream(data.path);
                                    readStream.pipe(res);
                                    //console.log(data.path)
                                    myResolve(data.path)
                                } catch (err) {
                                    myReject(err)
                                }

                            });
                        };
                     
                        send_report().then(function (data) {
                            if (1 == 1) {
                                fs.unlink(data, function (err) {
                                    if (err) {
                                        console.error(err);
                                        //throw err;

                                    } else {
                                        console.log("success remove! " + data);

                                    }
                                });
                            }
                        });


                    },
                        function (error) {
                            res.writeHead(200, { 'Content-Type': 'application/json' , 'Content-Disposition': 'attachment; filename="error.json"'});
                            res.end(error);
                        })
                    .then(function (data) {
                        // destroy template 
                        // detroay result
                    });
                // CARBONITA - end    

                //  console.log(files);
                //  console.log(fields);

                // ////--- TEST     
                // console.log('--------------------------------');
                // console.log('fields.report_type               :      ' + fields.report_type);
                // console.log('fields.report_name                     ' + fields.report_name);
                // console.log('fields.req_encoding                   ' + fields.req_encoding);
                // //  console.log('JSON.parse(fields.data_text)           ' + JSON.parse(fields.data_text));
                // console.log('fields.data_text                      ' + fields.data_text);
                // console.log('files.template_binary.path             ' + files.template_binary.filepath);
                // console.log('files.template_binary.originalFilename ' + files.template_binary.originalFilename);
                // console.log('files.template_binary.mimetype         ' + files.template_binary.mimetype);
                // console.log('--------------------------------');
                // res.writeHead(200, { 'Content-Type': 'application/json' });
                // res.end(JSON.stringify({ fields, files }, null, 2));
                // //// ---- TEST -END


                //    res.writeHead(200, {'Content-Type': job_result.mimetype || 'text/plain'  });
                //    var readStream = fs.createReadStream(job_result.path);
                //    readStream.pipe(res); 


                return;
            }


        });

    } catch (err) {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(err);
        next(err);
    }
}


module.exports.crbt_get = c_get;
module.exports.crbt_post = c_post;