#!/usr/bin/env node

var _ = require('underscore');
var filesFromDir = function(dir) {

    var fs = require("fs");
    var results = [];

    fs.readdirSync(dir).forEach(function(file) {
        file = dir+'/'+file;
        var stat = fs.statSync(file);
        if (stat && stat.isDirectory()) {
            results = results.concat( filesFromDir(file))
        } else results.push(file);
    });

    return results;
};

( function() {
    var set = ''
    _.each( filesFromDir('/home/codio/workspace/lib/'), function( file ) {
        set = file.replace(/.*?([^\/]+)\.coffee$/, "$1");    
        console.log( set )
    });
}.call(this) );