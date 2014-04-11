var Fiber = Npm.require('fibers');
var fs = Npm.require('fs');
var stylus = Npm.require('stylus');

Meteor.startup( function () {
    var strTemplate = ''
    _.each( _.keys( _.define ), function ( name ) {
        strTemplate += _.define[ name ].template;
    });
    
    fs.stat( _.style_file, function (err1, stats) {
        if ( err1 ) throw err1;       
        var style_mtime = stats.mtime;
        fs.stat( _.css_file, function (err2, _stats) {
            if ( err2 || style_mtime > _stats.mtime ) {
                fs.readFile( _.style_file, {encoding: 'utf8'}, function (err3, data ) { 
                    if ( err3 ) throw err3;
                    else {
                        var strCSS = stylus( data ).render();
                        // strCSS
                        if (! err2 )
                            fs.unlink( _.css_file, function (err4) { throw err4 });
                        fs.writeFile( _.css_file, strCSS, function (err5) { if ( err5 ) throw err5; });
                    }
                });
            }
        });
    });
});
