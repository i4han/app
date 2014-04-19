var _ = require('underscore');
var fs = require('fs');
var crypto = require('crypto');
var serialize = require('node-serialize');

require( 'coffee-script/register' );
var Config = require('../lib/config').__config__;
var __ = require('../lib/utilities').__;


var stringOrFunctionToString = function (what) {
    if (!what) {
        return ''; 
    } else if (typeof what == 'string') {
        return what;
    } else if (typeof what == 'function') {
        return what.call(this, Config);
    } else  throw "Error";
}



lib = { 
    storables: '/home/action/workspace/app/private/storables',
    readFile: function (file, callback) {
        fs.readFile( file, { encoding: 'utf8' }, function ( err, data ) {
            if (err) return callback(err);
            callback(null, data);
        });
    },
    readFileSync: function (file) {
        return fs.readFileSync(file, { encoding: 'utf8' })
    },
    writeFile: function (file, data) {
        fs.writeFile( file, data, function (err) { 
            if ( err ) throw err; 
        });
    },
    overwriteFile: function (file, data) {
        fs.writeFile( file, data, { encoding: 'utf8', flag: 'w+' }, function (err) { if (err) throw err; });
    },
    indentBlock: function (block, indent) {
        if ( indent ) {
            block = new String( block );
            block = block.replace( /^/gm, __.repeat( Config.indent_string, indent ) );
            block = block.toString();
        }
        return block
    }
}


_.extend( __, lib );

__.getStorables = function () {
    var content = __.readFileSync( Config.storables );
    content = ( content.length > 0 ) ? content : '{}';
    return serialize.unserialize( content );
}

__.saveStorables = function (data) {
    __.overwriteFile( Config.storables, serialize.serialize( data ) );
}


__.collectKey = function (obj, kind, storables_hash) {
    
    var strSum = '';
    var template = Config.pages[kind];
    
    var checkSum = function () {
        _.each( _.keys(obj), function ( file ) {
            _.each( _.keys( obj[file] ), function ( page ) {
                strSum += stringOrFunctionToString( obj[file][page][kind] );
            });
        });
        return crypto.createHash('md5').update( strSum ).digest('hex');
    }
    var updateFile = function () {
        console.log( 'Updating ' + template.target_file);
        var fileTarget = template.header ? template.header : '';
        _.each( _.keys(obj), function ( file ) { 
            _.each( _.keys(obj[file]), function ( page ) { 
                var block = stringOrFunctionToString( obj[file][page][kind] );
                if ( block ) {
                    block = __.indentBlock( block, template.indent );
                    var target = template.format.call( this, page, block );
                    fileTarget += target;
                }
            });
        });
        __.overwriteFile( template.target_file, fileTarget );        
    };
    
    var hash = checkSum();
    fs.exists( template.target_file, function (exists) {
        if (exists) {
            if ( storables_hash !== hash )
                updateFile();   
        } else
            updateFile();
    });
    return hash;
}


__.collectPages = function ( Pages ) {
   var storables = __.getStorables();
    _.each( Config.templates, function ( type ) {
        storables[type + '_hash'] = __.collectKey( Pages, type, storables[type + '_hash'] );
    });
    __.saveStorables( storables );
}


module.exports = __;
