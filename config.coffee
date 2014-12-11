vi if !Meteor?
    _ = require 'underscore'
    fs = require 'fs'
    stylus = require 'stylus'
else if ! Package.underscore._.isEmpty(@Config) and ! Package.underscore._.isEmpty(@__)
    return {Config:@Config, __:@__};
else
    _ = @_
    @module = exports:{}
    if Meteor.isServer
        fs = Npm.require 'fs'


main = {
    title:            'App'
    home_url:         'http://www.hi16.ca'
    autogen_prefix:   'auto_'
    callback_port:    3003
    init: ->
        if !Meteor? or Meteor.isServer
            @home_dir   = process.env.HOME + '/'
            @meteor_dir = process.env.METEOR_APP + '/'
            @source_dir = @meteor_dir + 'lib/'
            @target_dir = @meteor_dir + 'client/'
        return this
}.init()

@Config = {
    title:             main.title
    home_url:          main.home_url
    callback_port:     main.callback_port
#    sets:              'content dialog form layout login' .split ' '
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
            target_file: main.target_dir + main.autogen_prefix + '1.jade'
            indent: 1
            format: (name, block) ->     """template(name="#{name}")\n#{block}\n\n"""
        stylus:
            target_file: main.target_dir + main.autogen_prefix + '6.css'
            indent: 0
            format: (name, block) -> stylus( block ).render() + '\n'
        HTML:
            target_file: main.target_dir + main.autogen_prefix + '2.html'
            indent: 1
            format: (name, block) ->     """<template name="#{name}">\n#{block}\n</template>"""
        head:
            target_file: main.target_dir + main.autogen_prefix + '0.jade'
            indent: 1
            header: 'head\n'
            format: (name, block) -> block
        less:
            target_file: main.target_dir + main.autogen_prefix + '5.less'
            indent: 0
            format: (name, block) -> block
        css:
            target_file: main.target_dir + main.autogen_prefix + '4.css'
            indent: 0
            format: (name, block) -> block
        styl:
            target_file: main.target_dir + main.autogen_prefix + '3.styl'
            indent: 0
            format: (name, block) -> block
    auto_generated_files: []
    init: ->
        @redis = {}
        if !Meteor? or Meteor.isServer
            @config_file = main.meteor_dir + 'config.coffee'
            @meteor_dir  = main.meteor_dir
            @package_dir = main.meteor_dir + 'packages/'
            @config_js   = @package_dir    + 'sat/'
            @source_dir  = main.source_dir
            @target_dir  = main.target_dir
            @storables   = main.meteor_dir + 'private/storables'
            @set_prefix  = ''
            @autogen_prefix = main.autogen_prefix
            if !Meteor?
                @redis = (require 'redis').createClient()
            else
                @redis = (Npm.require 'redis').createClient()
                @server_config = @meteor_dir + 'server/config'
        @templates  = Object.keys @pages
        @auto_generated_files = (@pages[i].target_file for i in @templates)
        delete @init
        return this
    quit: ->
        @redis.quit() if ! _.isEmpty( @redis )    
}.init()



@__ =
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
        
@__.renameKeys = (obj, keyObject) ->
    _.each _.keys keyObject, (key) -> @__.reKey obj, key, keyObject[key]

@__.repeat = (pattern, count) ->
    return '' if count < 1
    result = ''
    while count > 0
        result += pattern if count & 1
        count >>= 1
        pattern += pattern
    result

@__.deepExtend = (target, source) ->
    for prop of source
        if prop of target
            @__.deepExtend target[prop], source[prop]
        else
            target[prop] = source[prop]
    target


@__.flatten = (obj, chained_keys) ->
    toReturn = {}       
    for i in obj
        if typeof obj[i] == 'object'
            flatObject = @__.flatten obj[i]
            for j in flatObject
                if chained_keys
                    toReturn[i+'_'+j] = flatObject[j]
                else
                    toReturn[j] = flatObject[j]
        else
            toReturn[i] = obj[i]
    toReturn

@__.log = (arg) ->
    if this.Config.redis.connected
        this.Config.redis.rpush( 'log', arg + '' );
    else
        console.log( arg + '' );

if !Meteor?
    module.exports = {
        __: @__,
        Config: @Config
    }
