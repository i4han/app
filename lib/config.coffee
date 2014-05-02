if !Meteor?
    _ = require 'underscore'
    fs = require 'fs'
    stylus = require 'stylus'
else if Meteor.isServer
    fs = Npm.require 'fs'

main = {
    title:            'App'
    home_url:         'http://www.hi16.ca'
    autogen_prefix:   'auto_generated'
    callback_port:    3003
    init: ->
        if !Meteor? or Meteor.isServer
            this.home_dir   = process.env.HOME + '/'
            this.meteor_dir = process.env.METEOR_APP + '/'
            this.source_dir = this.meteor_dir + 'lib/'
            this.target_dir = this.meteor_dir + 'client/lib/'
        return this
}.init()

module.exports.Config = {
    title:             main.title
    home_url:          main.home_url
    callback_port:     main.callback_port
    sets:              'content dialog form layout login' .split ' '
    indent_string:     '    '
    collections:       'connects items updates boxes colors' .split ' '
    instagram:
        callback_path:     '/callback/instagram/'
        response_type:     'code'
        grant_type:        'authorization_code'
        oauth_url:         'https://api.instagram.com/oauth/authorize/'
        client_id:         '91ee62d198554e1c83305df1dc007335'
        final_url:          main.home_url
        request_url:       'https://api.instagram.com/oauth/access_token/'
        subscription_url:  'https://api.instagram.com/v1/subscriptions/'
        callback_url:      'http://www.hi16.ca:3003/callback/instagram/?command=update'
        media_url:         (media_id, access_token) -> 
            "https://api.instagram.com/v1/media/#{media_id}/?access_token=#{access_token}"
        redirect_uri:      ( user_id ) ->  # redirect_uri is instagram's definition.
            "http://www.hi16.ca:3003/callback/instagram/?command=oauth&user_id=#{user_id}"        
    pages:
        jade:
            target_file: main.target_dir + main.autogen_prefix + '.jade'
            indent: 1
            format: (name, block) ->     """template(name="#{name}")\n#{block}\n\n"""
        stylus:
            target_file: main.target_dir + main.autogen_prefix + 'z.css'
            indent: 0
            format: (name, block) -> stylus( block ).render() + '\n'
        HTML:
            target_file: main.target_dir + main.autogen_prefix + '.html'
            indent: 1
            format: (name, block) ->     """<template name="#{name}">\n#{block}\n</template>"""
        head:
            target_file: main.target_dir + main.autogen_prefix + '_head.jade'
            indent: 1
            header: 'head\n'
            format: (name, block) -> block
        less:
            target_file: main.target_dir + main.autogen_prefix + '.less'
            indent: 0
            format: (name, block) -> block
        css:
            target_file: main.target_dir + main.autogen_prefix + '.css'
            indent: 0
            format: (name, block) -> block
        styl:
            target_file: main.target_dir + main.autogen_prefix + '.styl'
            indent: 0
            format: (name, block) -> block
    auto_generated_files: []
    init: ->
        this.redis = {}
        if !Meteor? or Meteor.isServer
            this.meteor_dir = main.meteor_dir
            this.source_dir = main.source_dir
            this.target_dir = main.target_dir
            this.lib_file   = main.meteor_dir + 'lib/utilities.js'
            this.storables  = main.meteor_dir + 'private/storables'
            this.set_prefix = 'set_'
            this.autogen_prefix = main.autogen_prefix
            if !Meteor?
                this.redis = (require 'redis').createClient()
            else
                this.redis = (Npm.require 'redis').createClient()
                this.server_config = this.meteor_dir + 'server/config'
        this.templates  = Object.keys this.pages
        this.auto_generated_files = (this.pages[i].target_file for i in this.templates)
        delete this.init
        return this
    quit: ->
        this.redis.quit() if ! _.isEmpty( this.redis ) 
        
}.init()



__ =
    queryString: (obj) ->
        parts = []
        for i of obj
            parts.push encodeURIComponent(i) + "=" + encodeURIComponent(obj[i])
        parts.join "&"

    trim: (str) -> str.trim()
    capitalize: (string) -> string.charAt(0).toUpperCase() + string.slice(1)
    dasherize: (str) -> str.trim().replace(/([A-Z])/g, "-$1").replace(/[-_\s]+/g, "-").toLowerCase()
    prettyJSON: (obj) -> JSON.stringify obj, null, 4

    getValue: (id) ->
        element = document.getElementById(id)
        (if element then element.value else null)

    trimmedValue: (id) ->
        element = document.getElementById(id)
        (if element then element.value.replace(/^\s*|\s*$/g, "") else null)

    reKey: (obj, oldName, newName) ->
        if obj.hasOwnProperty(oldName)
            obj[newName] = obj[oldName]
            delete obj[oldName]
        this
        
__.renameKeys = (obj, keyObject) ->
    _.each _.keys keyObject, (key) ->
        __.reKey obj, key, keyObject[key]

__.repeat = (pattern, count) ->
    return '' if count < 1
    result = ''
    while count > 0
        result += pattern if count & 1
        count >>= 1
        pattern += pattern
    result

__.deepExtend = (target, source) ->
    for prop of source
        if prop of target
            __.deepExtend target[prop], source[prop]
        else
            target[prop] = source[prop]
    target


__.flatten = (obj, chained_keys) ->
    toReturn = {}       
    for i in obj
        if typeof obj[i] == 'object'
            flatObject = __.flatten obj[i]
            for j in flatObject
                if chained_keys
                    toReturn[i+'_'+j] = flatObject[j]
                else
                    toReturn[j] = flatObject[j]
        else
            toReturn[i] = obj[i]
    toReturn

__.log = (arg) ->
    if Config.redis.connected
        Config.redis.rpush( 'log', arg + '' );
    else
        console.log( arg + '' );

module.exports.__ = __;
