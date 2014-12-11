var fs = require('fs');
fs.createReadStream('main.coffee')
    .pipe(console.log)
    .pipe(fs.createWriteStream('out.coffee'));