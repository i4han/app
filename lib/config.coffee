ß#!/usr/bin/env coffee
# Source code is config.orgin other files are compiled by the source.
# config.coffee -> include | coffee -sc --bare -> config.js
# sat/config.js used by Cakefile, Meteor, dsync, collect

if !Meteor?
    _ = require 'underscore'
    fs = require 'fs'
    jade = require 'jade'
    stylus = require 'stylus'
else
    return {Config:@Config, __:@__} unless Package.underscore._.isEmpty(@Config) or Package.underscore._.isEmpty(@__)
    _ = @_
    @module = exports:{}
    fs = Npm.require 'fs' if Meteor.isServer


main = {
    autogen_prefix:   'auto_'
    callback_port:    3003
    init: ->
        if !Meteor? or Meteor.isServer
            @home_dir   = process.env.HOME + '/'
            @workspace  = @home_dir   + 'workspace/'
            @site_dir   = @workspace  + 'site/'
            @module_dir = @workspace  + 'lib/'            
            @meteor_dir = @workspace  + 'app/'
            @source_dir = @meteor_dir + 'lib/'
            @target_dir = @meteor_dir + 'client/'
        return this
}.init()

local = {}
    
#include local <- This is where local config files to be located.

@Config = {
    title:             local.title
    home_url:          local.home_url
    callback_port:     main.callback_port
    indent_string:     '    '
    local_config:      'local.coffee'
    collections:       local.collections
    $:                 local.$
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
            format: (name, block) -> """template(name="#{name}")\n#{block}\n\n"""
        jade$:
            target_file: main.target_dir + main.autogen_prefix + '2.html'
            indent: 1
            format: (name, block) -> jade.compile( """template(name="#{name}")\n#{block}\n\n""", null )()  
        HTML:
            target_file: main.target_dir + main.autogen_prefix + '3.html'
            indent: 1
            format: (name, block) -> """<template name="#{name}">\n#{block}\n</template>"""
        head:
            target_file: main.target_dir + main.autogen_prefix + '0.jade'
            indent: 1
            header: 'head\n'                  #  'doctype html\n' has not suppored by jade
            format: (name, block) -> block
        less:
            target_file: main.target_dir + main.autogen_prefix + '7.less'
            indent: 0
            format: (name, block) -> block
        css:
            target_file: main.target_dir + main.autogen_prefix + '5.css'
            indent: 0
            format: (name, block) -> block
        styl:
            target_file: main.target_dir + main.autogen_prefix + '4.styl'
            indent: 0
            format: (name, block) -> block
        styl$:
            target_file: main.target_dir + main.autogen_prefix + '6.css'
            indent: 0
            format: (name, block) -> stylus( block ).render() + '\n'

    auto_generated_files: []
    init: ->
        @redis = {}
        if !Meteor? or Meteor.isServer
            @meteor_dir    = main.meteor_dir
            @meteor_lib    = @meteor_dir + 'lib/'
            @package_dir   = @meteor_dir + 'packages/'
            @config_js_dir = @package_dir   + 'sat/'
            @config_js     = @config_js_dir + 'config.js'
            @module_dir    = main.module_dir
            @config_source = @module_dir + '/config.coffee'
            @site_dir      = main.site_dir
            @sync_dir      = @meteor_lib
            @source_dir    = main.source_dir
            @target_dir    = main.target_dir
            @storables     = main.meteor_dir + 'private/storables'
            @set_prefix    = ''
            @autogen_prefix = main.autogen_prefix
            if !Meteor?               
                redis = require 'redis'
                @redis = redis.createClient()
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

    trim: (str) -> if str? then str.trim() else null
    capitalize: (string) -> string.charAt(0).toUpperCase() + string.slice(1)
    dasherize: (str) -> str.trim().replace(/([A-Z])/g, "-$1").replace(/[-_\s]+/g, "-").toLowerCase()
    prettyJSON: (obj) -> JSON.stringify obj, null, 4
    getValue: (id) ->
        element = document.getElementById(id)
        if element then element.value else null
    trimmedValue: (id) ->
        element = document.getElementById(id)
        if element then element.value.replace(/^\s*|\s*$/g, "") else null
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
    module.exports =
        __: @__
        Config: @Config
