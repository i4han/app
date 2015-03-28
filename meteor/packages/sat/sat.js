
db = {}, Pages = {};
Sat = { isServer: false, isClient: false };
Config = this.Config
module = { exports:{} } // why

db_init = function () {
    _.each( Config.collections, function (c) {
        if ( 'undefined' === typeof db[c] ) {
            db[c] = new Meteor.Collection(c);
            if (Meteor.isServer) {
                db[c].allow({
                    insert: function (doc) { return true; },
                    update: function (userId, doc, fields, modifier) { return true; }, 
                    remove: function (userId, doc) { return true; } 
                });
                db[c].deny({
                    update: function (userId, doc, fields, modifier) { return false; }, 
                    remove: function (userId, doc) { return false; } 
                });

                Meteor.publish( c, function () { return db[c].find({}); });
            } else if (Meteor.isClient)
                Meteor.subscribe( c );
        }
    });
}


if (Meteor.isClient) {
    $( function ($) { 
        if (!Sat.isClient)
            Sat.init();
        for (key in x) {
            $.fn[key] = x.$[key]
        }
    });
} else if (Meteor.isServer) {
    Meteor.startup(function() {
        if ( ! Sat.isServer ) 
            Sat.init();            
    });
}


Sat.init = function () {
    db_init();
    var pages_in_file = {};
    pages_in_file = module.exports;

    if (Meteor.isServer) {
        Sat.isServer = true;
        Meteor.methods({
            
        });

    } else if (Meteor.isClient) {
        Sat.isClient = true;
        Router.configure({layoutTemplate: 'layout'});

        var startup = [];
        _.each(_.keys(pages_in_file), function(file) {
            if ( x.isLowerCase(file, 0) )
                _.extend( Pages, pages_in_file[file] );

            // __events__.startup
            if (pages_in_file[file].__events__ && pages_in_file[file].__events__.startup) {
                startup.push(pages_in_file[file].__events__.startup);
                delete pages_in_file[file].__events__.startup
            }
            // delete Pages if page name startwith __
            _.each( _.filter( _.keys( pages_in_file[file] ), function (key) { 
                    return ! ( (x.isLowerCase(key, 0) || key.charAt(0) === '_') && x.isLowerCase(key, 1) );  // remove pages those name is not 'smallcase' or '_smallcase'
                }), function (name) {
                    delete Pages[name];
            });
        });
        var router_map = {};
        _.each(_.keys(Pages), function(name) {           // Pages name: key:  name should be unique.
            _.each(_.keys(Pages[name]), function(key) {  // __key will be ignored including __events__. Defined keys = [helpers, events, router]
                if (key.substring(0, 2) !== '__' && _.indexOf(Config.templates, key) === -1 ) 
                    if (key === 'helpers')
                        Template[name].helpers( Pages[name].helpers );
                    else if (key === 'events') {
                        var obj = Pages[name].events;
                        if ( typeof(obj) === 'function' )
                            Template[name].events( obj() );
                        else                            
                            Template[name].events( obj );
                    } else if (key === 'router') {
                        router_map[name] = Pages[name].router;
                    } else if (key === 'startup') {
                        startup.push( Pages[name].startup );
                    //    delete Pages[name].router;
                    } else if ( ['rendered', 'created', 'destroyed'].indexOf(key) !== -1)
                        if (Template[name])
                            Template[name][key] = Pages[name][key];
                        else
                            x.log( 'Template ' + name + ' key:' + key );
            });
        });
        Router.map( function () {
            for (var key in router_map)
                this.route( key, router_map[key] );
        });
        if (startup)  // Set startup fuctions.
            Meteor.startup(function() {
                _.each(startup, function(func) { func() });
            });

    }
}

