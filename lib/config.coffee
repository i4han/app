#!/usr/bin/env coffee
# Source code is config.orgin other files are compiled by the source.
# config.coffee -> include | coffee -sc --bare -> config.js
# sat/config.js used by Cakefile, Meteor, dsync, collect

if !Meteor?
    _      = require 'underscore'
    fs     = require 'fs'
    jade   = require 'jade'
    stylus = require 'stylus'
else
    return {Config:@Config, __:@__} unless Package.underscore._.isEmpty(@Config) or Package.underscore._.isEmpty(@__)
    _ = @_
    @module = exports:{}
    fs = Npm.require 'fs' if Meteor.isServer

main = {
    autogen_prefix:   'auto_'
    callback_port:    3300
    local_config:     'local.coffee'
    init: ->
        if !Meteor? or Meteor.isServer
            @home_dir   = process.env.HOME + '/'
            @workspace  = @home_dir   + 'workspace/'
            @site_dir   = if process.env.site then @workspace + process.env.site + '/' 
            else process.env.SITE + '/'
            @module_dir = @workspace  + 'lib/'            
            @meteor_dir = @site_dir   + 'app/'
            @source_dir = @meteor_dir + 'lib/'
            @target_dir = @meteor_dir + 'client/'
        return this
}.init()

#include theme

local = {}
    
#include local <- This is where local config files to be located.

@Config = {
    title:         local.title
    home_url:      local.home_url
    callback_port: main.callback_port
    indent_string: '    '
    local_config:  main.local_config
    collections:   local.collections
    menu:          local.menu
    _:
        font_style:    
            pt_sans:    "https://fonts.googleapis.com/css?family=PT+Sans:400,700"
    $:             theme[local.theme] if theme?[local.theme]?
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
            file: main.target_dir + main.autogen_prefix + '1.jade'
            indent: 1
            format: (name, block) -> """template(name="#{name}")\n#{block}\n\n"""
        jade$:
            file: main.target_dir + main.autogen_prefix + '2.html'
            indent: 1
            format: (name, block) -> jade.compile( """template(name="#{name}")\n#{block}\n\n""", null )()  
        HTML:
            file: main.target_dir + main.autogen_prefix + '3.html'
            indent: 1
            format: (name, block) -> """<template name="#{name}">\n#{block}\n</template>\n"""
        head:
            file: main.target_dir + main.autogen_prefix + '0.jade'
            indent: 1
            header: 'head\n'                  #  'doctype html\n' has not suppored by jade
            format: (name, block) -> block + '\n'
        less:
            file: main.target_dir + main.autogen_prefix + '7.less'
            indent: 0
            format: (name, block) -> block + '\n'
        css:
            file: main.target_dir + main.autogen_prefix + '5.css'
            indent: 0
            format: (name, block) -> block + '\n'
        styl:
            file: main.target_dir + main.autogen_prefix + '4.styl'
            indent: 0
            format: (name, block) -> block + '\n\n'
        styl$:
            file: main.target_dir + main.autogen_prefix + '6.css'
            indent: 0
            format: (name, block) -> stylus( block ).render() + '\n'

    auto_generated_files: []
    init: ->
#        @redis = {}
        if !Meteor? or Meteor.isServer
            @meteor_dir    = main.meteor_dir
            @index_file    = local.index_file
            @module_dir    = main.module_dir
            @source_dir    = main.source_dir
            @client_dir    = main.target_dir
            @target_dir    = main.target_dir   # alias client_dir
            @site_dir      = main.site_dir
            @build_dir     = @site_dir       + 'build/'
            @meteor_lib    = @meteor_dir     + 'lib/'
            @packages      = main.workspace  + 'meteor/packages/'
            @site_packages = @site_dir       + 'app/packages/'
            @config_js_dir = @site_dir       + 'app/packages/sat/'
            @sync_dir      = @site_dir       + 'app/lib/' #@meteor_lib  # after meteor_lib
            @config_js     = @config_js_dir  + 'config.js'
            @config_source = @module_dir     + 'config.coffee'
            @index_module  = @site_dir       + local.index_file 
            @local_source  = @site_dir       + main.local_config
            @local_module  = @site_dir       + main.local_config # 'local.coffee'
            @theme_source  = @module_dir     + 'theme.coffee'
            @header_source = @module_dir     + 'header.coffee'
#           @storables     = main.meteor_dir + 'private/storables' # remove?
            @log_file      = main.home_dir   + '.log.io/satellite'
            @set_prefix    = ''
            @autogen_prefix = main.autogen_prefix            
            if !Meteor?               
#                redis = require 'redis'
#                 @redis = redis.createClient()
                a = '' # useless                 
            else
#                @redis = (Npm.require 'redis').createClient()
                @server_config = @meteor_dir + 'server/config'

        @templates  = Object.keys @pages
        @auto_generated_files = (@pages[i].file for i in @templates)
        delete @init
        return this
    quit: (func) ->
#        @redis.quit() if ! _.isEmpty( @redis )
        func() if func?
}.init()

!Meteor? and module.exports = __: @__, Config: @Config

###

@__.slice = (str, tab=1, indent='    ') -> (((str.replace /~\s+/g, '').split '|').map (s) ->
    s = if 0 == s.search /^(<+)/ then s.replace /^(<+)/, Array(tab = Math.max tab - RegExp.$1.length, 1).join indent 
    else if 0 == s.search /^>/ then s.replace /^>/, Array(++tab).join indent 
    else s.replace /^/, Array(tab).join indent).join '\n'


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


@__.insertTemplate = (page, id, data={}) ->
    $('#' + id).empty()
    Blaze.renderWithData(
        Template[page], 
        if Object.keys(data).length then data else Template[page].helpers 
        document.getElementById id  )

@__.currentRoute = -> Router.current().route.getName()

@__.render = (page) -> Template[page].renderFunction().value

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
     console.log( arg + '' );
###
#    if this.Config.redis.connected
#        this.Config.redis.rpush( 'log', arg + '' );
#    else
