if ( 'undefined' === typeof Meteor ) {
    var fs = require('fs');
    require( 'coffee-script/register' );
    Config = require('./config').__config__;
} else if ( Meteor.isServer ) {
    var fs = Npm.require('fs');
    Config = module.exports.__config__;
} else
    var Config = false; 


var __ = {

    queryString: function (obj) {
        var parts = [];
        for ( var i in obj ) {
            if ( obj.hasOwnProperty( i ) ) {
                parts.push( encodeURIComponent( i ) + "=" + encodeURIComponent( obj[ i ] ) );
            }
        }
        return parts.join( "&" );
    },
    trim: function (str) {
        return str.trim();
    },
    dasherize: function (str) {
        return __.trim(str).replace(/([A-Z])/g, '-$1').replace(/[-_\s]+/g, '-').toLowerCase();
    },
    prettyJSON: function (obj) {
        return JSON.stringify(obj, null, 4);
    },
    
    /* for client */
    getValue: function ( id ) {
        var element = document.getElementById( id );
        return element ? element.value : null;
    },
    trimmedValue: function ( id ) {
        var element = document.getElementById( id );
        return element ? element.value.replace(/^\s*|\s*$/g, "") : null;
    },
    reKey: function (obj, oldName, newName) {
        if (obj.hasOwnProperty(oldName)) {
            obj[newName] = obj[oldName];
            delete obj[oldName];
        }
        return this;
    },
    repeat: function (pattern, count) {
        if (count < 1) return '';
        var result = '';
        while (count > 0) {
            if (count & 1) result += pattern;
            count >>= 1, pattern += pattern;
        }
        return result;
    }
}

__.renameKeys = function (obj, keyObject) {
    _.each( _.keys( keyObject ), function (key) {
        __.reKey( obj, key, keyObject[key] );
    });
}

__.deepExtend = function (target, source) {
    for (var prop in source)
        if (prop in target)
            __.deepExtend(target[prop], source[prop]);
        else
            target[prop] = source[prop];
    return target;
}

__.flatten = function (obj, chained_keys) {
    var toReturn = {};        
    for ( var i in obj )
        if ( (typeof obj[i]) == 'object' ) {
            var flatObject = __.flatten(obj[i]);
            for (var x in flatObject)
                if ( chained_keys )
                    toReturn[i+'_'+x] = flatObject[x];
                else
                    toReturn[x] = flatObject[x];
        } else
            toReturn[i] = obj[i];
    return toReturn;
}


__.log = function ( arg ) {
    fs.appendFile( Config.log_file, arg.toString() + '\n', function (err) {
        if (err) throw err;
    });
}

module.exports.__ = __;