
collections = x.toArray Meteor.settings.public.collections

db_server = ->
    collections.map (collection) ->
        db[collection] = new Meteor.Collection collection
        db[collection].allow
            insert: (doc) -> true
            update: (userId, doc, fields, modifier) -> true 
            remove: (userId, doc) -> true
        db[collection].deny
            update: (userId, doc, fields, modifier) -> false
            remove: (userId, doc) -> false
        Meteor.publish collection, -> db[collection].find {}

db_client = ->
    collections.map (collection) ->
        db[collection] = new Meteor.Collection collection
        Meteor.subscribe collection


Meteor.startup ->
    x.keys(module.exports).map (file) ->
        Pages[key] = val for key, val of module.exports[file]
        x.keys(module.exports[file]).filter((key) -> key[0..1] == '__').map (name) -> delete Pages[name]
    if Meteor.isServer
        db_server()
        x.keys(Pages).map (name) -> (methods = Pages[name].methods) and Meteor.methods methods
    else if Meteor.isClient
        db_client()
        Router.configure layoutTemplate: 'layout'
        x.keys(Pages).map (name) -> 
            _ = Pages[name]  
            _.onStartup and Pages[name].onStartup.call(window)
            _.router    and Router.map -> @route name, Pages[name].router
            _.events    and Template[name].events  x.func Pages[name].events
            _.helpers   and Template[name].helpers x.func Pages[name].helpers
            _.on$Ready  and $ ($) -> Pages[name].on$Ready.call(window)
            ('onCreated onRendered onDestroyed'.split ' ').forEach (d) -> 
                _[d] and Template[name][d] -> Pages[name][d].call(window)
        $ ($) -> 
            o.$.map (f) -> f()
            $.fn[k] = x.$[k] for k of x.$

