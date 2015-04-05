
db.server = ->
    Meteor.settings.public.collections.map (collection) ->
        console.log collection
        db[collection] = new Meteor.Collection collection
        db[collection].allow
            insert: (doc) -> true
            update: (userId, doc, fields, modifier) -> true 
            remove: (userId, doc) -> true
        db[collection].deny
            update: (userId, doc, fields, modifier) -> false
            remove: (userId, doc) -> false
        Meteor.publish collection, -> db[collection].find {}

db.client = ->
    Meteor.settings.public.collections.map (collection) ->
        db[collection] = new Meteor.Collection collection
        Meteor.subscribe collection

Pages.init = ->
    delete Pages.init
    pagesInFile = module.exports
    (x.keys pagesInFile).map (file) ->
        Pages[key] = val for key, val of pagesInFile[file] if file[0..1] != '__'
        (( x.keys pagesInFile[file] ).filter (key) -> key[0..1] == '__').map (name) -> delete Pages[name]

Sat.init = ->
    Pages.init()
    if Meteor.isServer
        db.server()
        methods = {}
        (x.keys Pages).map (name) -> (x.keys Pages[name]).map (key) ->  
            methods[k] = v for k, v of Pages[name][key] if 'methods' == key
        Meteor.methods methods
    else if Meteor.isClient
        db.client()
        Router.configure layoutTemplate: 'layout'
        startup = []
        router_map = {}
        atRendered = []
        (x.keys Pages).map (name) -> (x.keys Pages[name]).map (key) ->  
            if 'startup' == key
                startup.push Pages[name].startup
            else if 'atRendered' == key
                obj = x.func Pages[name].atRendered
                (x.keys obj).map (k) -> (x.keys obj[k]).map (l) ->
                    if   'removeClass' == l then atRendered.push -> $(k).removeClass obj[k][l]
                    else if 'addClass' == l then atRendered.push -> $(k).addClass obj[k][l]
                    else atRendered.push -> $(k).css l, x.value obj[k][l]
            else if 'onRendered' == key
                Template[name][key] -> 
                    Pages[name][key]() 
                    atRendered.map (f) -> f()
            else if 'router' == key 
                router_map[name] = Pages[name].router
            else if key in 'eco navbar'.split ' ' # Config.templates.concat 
                ''
            else if key in 'events helpers'.split ' '
                Template[name][key] x.func Pages[name][key]
            else if key in 'onCreated onDestroyed'.split ' '
                Template[name][key] Pages[name][key]
        Router.map ->
            this.route key, router_map[key] for key of router_map
        Meteor.startup -> startup.map (func) -> func()

if Meteor.isClient
    $ ($) -> 
        Sat.init()
        $.fn[k] = x.$[k] for k of x.$
else if Meteor.isServer
    Meteor.startup -> Sat.init()

