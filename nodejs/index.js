 
const express = require("express");


var app = express();

const method_handler = require('./lib/lib-1-web.js');
const PORT = 80;


app.route('/')

.get(method_handler.crbt_get)
  .post(method_handler.crbt_post)

app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`)
})




