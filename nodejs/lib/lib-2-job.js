
const steps = require("./lib-3-steps.js");


class TheResult {
    constructor(path, mimetype) {
        this.path = path;
        this.mimetype = mimetype;
    }
}

function log1(p) {
    console.log(p);
    console.log('error somewhere!');
}


async function job(fields, files, response, next) {
    return new Promise(function (myResolve, myReject) {

        console.log('0--')
        let l_result = new TheResult();
        if (1 == 1) {
            //console.log(files);

            steps.myPromise01_parse(fields, files)
                .then(function (data) {
                    steps.myPromise02_render(data)
                        .then(function (data) {
                            steps.myPromise03_write(data)
                                .then(function (data) {
                                    steps.myPromise04_send(response, data)
                                        .then(function (data) {
                                            l_result = data;
                                            steps.myPromise04_destroy(data).then(
                                                function (data) {
                                                    console.log('-end-');
                                                    console.log('-----');
                                                    myResolve(l_result);
                                                }, function (error) { console.log('error-4'); log1(error); }
                                            )
                                        }, function (error) { console.log('error-3'); log1(error); })
                                }, function (error) { console.log('error-2'); log1(error); }
                                )
                        }, function (error) { console.log('error-1'); log1(error); }
                        )
                }
                    , log1)
                .then(function (data) {

                    console.log('- all jobs  initiated-')
                }
                );
        };

    });




}


module.exports.job = job;
module.exports.TheResult = TheResult;
