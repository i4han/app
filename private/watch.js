#!/home/action/.nvm/v0.10.11/bin/node

var home_dir = '/home/action/workspace/app/';

Watch = {
    watch_file: home_dir + 'private/hot.stylus',
    css_file: home_dir + 'main.css',
    content: ''
}

var fs = require('fs');
var stylus = require('stylus');
var strContent = '';
var strCSS = '';

console.log( 'Watching ' + Watch.watch_file );
fs.watchFile( Watch.watch_file, function ( curr, prev ) {
    fs.readFile( Watch.watch_file, {encoding: 'utf8'}, function ( err, data ) { 
        if ( err ) {
            throw err;
        } else {
            console.log( 'Updating ' + Watch.css_file );
            strCSS = stylus( data ).render();
            fs.unlink( Watch.css_file, function ( err ) {});
            fs.writeFile( Watch.css_file, strCSS, function (err) { if ( err ) throw err; });
        }
    });
});
