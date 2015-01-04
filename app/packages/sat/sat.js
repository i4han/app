db = {}, Pages = {};
Sat = { isServer: false, isClient: false };
__ = this.__
Config = this.Config
module = { exports:{} } // why?

__.deepExtend = function (target, source) {
    for (var prop in source)
        if (prop in target)
            __.deepExtend(target[prop], source[prop]);
        else
            target[prop] = source[prop];
    return target;
}


__.capitalize = function (string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

__.isLowerCase = function (char, index) {
    return char.charAt(index) >= 'a' && char.charAt(index) <= 'z' ? true : false
}

db.init = function () {
    db.collections = Config.collections;
    _.each( db.collections, function (collection) {
        var Collection = __.capitalize(collection)
        if ( 'undefined' === typeof db[ Collection ] )
            db[ Collection ] = new Meteor.Collection(collection);
    });
}


if ( Meteor.isClient ) {
    $( function () { 
        if ( ! Sat.isClient ) 
            Sat.init(); 
    });
} else if ( Meteor.isServer ) {
    Meteor.startup( function() {
        if ( ! Sat.isServer ) 
            Sat.init();            
    });
}


Sat.init = function () {
    db.init();
    var pages_in_file = module.exports;
    if ( Meteor.isServer ) {
        Sat.isServer = true;
        __.deepExtend( Config, module.exports.ServerConfig );
        delete module.exports.ServerConfig;
    } else if ( Meteor.isClient ) {
        Sat.isClient = true;
        Router.configure({ layoutTemplate: 'layout' });
        
        var startup = [];
        _.each(_.keys(pages_in_file), function(file) {
            if ( __.isLowerCase(file, 0) )
                _.extend( Pages, pages_in_file[file] );
            if (pages_in_file[file].__events__ && pages_in_file[file].__events__.startup) {
                startup.push(pages_in_file[file].__events__.startup);
                delete pages_in_file[file].__events__.startup
            }
            _.each( _.filter( _.keys( pages_in_file[file] ), function (key) { 
                    return ! ( (__.isLowerCase(key, 0) || key.charAt(0) === '_') && __.isLowerCase(key, 1) );  // remove pages those name is not 'smallcase' or '_smallcase'
                }), function (name) {
                    delete Pages[name];
            });
        });
        if (startup)  // Set startup fuctions.
            Meteor.startup(function() {
                _.each(startup, function(func) { func() });
            });
        var router_map = {};
        _.each(_.keys(Pages), function(name) {           // Pages name: key:  name should be unique.
            _.each(_.keys(Pages[name]), function(key) {  // __key will be ignored including __events__. Defined keys = [helpers, events, router]
                if (key.substring(0, 2) !== '__' && _.indexOf(Config.templates, key) === -1 ) 
                    if (key === 'helpers')
                        Template[name].helpers( Pages[name].helpers );
                    else if (key === 'events')
                        Template[name].events( Pages[name].events );
                    else if (key === 'router') {
                        router_map[name] = Pages[name].router;
                    //    delete Pages[name].router;
                    } else if ( ['rendered', 'created', 'destroyed'].indexOf(key) !== -1)
                        if (Template[name])
                            Template[name][key] = Pages[name][key];
                        else
                            console.log( 'Template ' + name + ' key:' + key );
            });
        });
        Router.map( function () {
            for (var key in router_map)
                this.route( key, router_map[key] );
        });
    }
}

