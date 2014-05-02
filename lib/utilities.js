if ( 'undefined' === typeof Meteor ) {
    var _ = require('underscore');
    require( 'coffee-script/register' );
    config = require('./config');
    Config = config.Config;
    __ = config.__
} else {
    Sat.config();
    var _ = Package.underscore._;
}


_.extend(__, {

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
    capitalize: function (string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
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
    }
});

__.renameKeys = function (obj, keyObject) {
    _.each( _.keys( keyObject ), function (key) {
        __.reKey( obj, key, keyObject[key] );
    });
}

/*
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
    if ( rc ) 
        rc.rpush( 'log', (arg + '').toString() );
    else
        console.log( (arg + '').toString() );
}
*/

module.exports.__ = __;


