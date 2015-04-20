
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
    x.keys(module.exports).map (file) -> Module[key] = val for key, val of module.exports[file]
    x.keys(Module).filter (name) -> name[0..1] == '__' and delete Module[name]
    if Meteor.isServer
        db_server()
        x.keys(Module).map (name) -> (methods = Module[name].methods) and Meteor.methods methods
    else if Meteor.isClient
        db_client()
        Router.configure layoutTemplate: 'layout'
        x.keys(Module).map (name) ->
            console.log name
            _ = Module[name]  
            _.onStartup and Module[name].onStartup.call(window)
            _.router    and Router.map -> @route name, Module[name].router
            _.events    and Template[name].events x.tideEventKey x.func(Module[name].events), Module[name].block + '-' + name
            _.helpers   and Template[name].helpers x.func Module[name].helpers
            _.on$Ready  and $ ($) -> Module[name].on$Ready.call(window)
            ('onCreated onRendered onDestroyed'.split ' ').forEach (d) -> 
                _[d] and Template[name][d] -> Module[name][d].call(window, name)
        $ ($) -> 
            o.$.map (f) -> f()
            $.fn[k] = x.$[k] for k of x.$

