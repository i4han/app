if !Meteor?
    stylus = require 'stylus'

main = {
    title:            'App'
    home_url:         'http://www.hi16.ca'
    home_dir:         '/home/action/'
    autogen_prefix:   'auto_generated'
    callback_port:    3003
    init: ->
        this.meteor_dir = this.home_dir   + 'workspace/app/'
        this.source_dir = this.meteor_dir + 'lib/'
        this.target_dir = this.meteor_dir + 'client/lib/'
        this.late_target_dir = this.meteor_dir + 'client/'
        delete this.init
        return this
}.init()

module.exports.Config = {
    title:             main.title
    home_url:          main.home_url
    meteor_dir:        main.meteor_dir
    callback_port:     main.callback_port
    style_file:        main.meteor_dir + 'client/hot.style' # no use.
    css_file:          main.meteor_dir + 'main.css'
    log_file:          main.home_dir   + 'meteor.log'
    lib_file:          main.meteor_dir + 'lib/utilities.js'
    storables:         main.meteor_dir + 'private/storables'
    autogen_prefix:    main.autogen_prefix
    set_prefix:        'set_'
    sets:              'content dialog form layout login' .split ' '
    indent_string:     '    '
    collections:       'connects items updates boxes colors' .split ' '
    init: ->
        # if !Meteor? sets = ls of set_* in home/lib (*) part.
        this.templates  = Object.keys this.pages
        this.watch_files = this.pages[i].target_file for i in this.templates
        delete this.init
        return this
    instagram:
        callback_path: '/callback/instagram/'
        response_type: 'code'
        grant_type:    'authorization_code'
        oauth_url:     'https://api.instagram.com/oauth/authorize/'
        client_id:     '91ee62d198554e1c83305df1dc007335'
        final_url:     main.home_url
        request_url:       'https://api.instagram.com/oauth/access_token/'
        subscription_url:  'https://api.instagram.com/v1/subscriptions/'
        callback_url:      'http://www.hi16.ca:3003/callback/instagram/?command=update'
        media_url:     (media_id, access_token) -> 
            "https://api.instagram.com/v1/media/#{media_id}/?access_token=#{access_token}"
        redirect_uri:  ( user_id ) ->  # redirect_uri is instagram's definition.
            "http://www.hi16.ca:3003/callback/instagram/?command=oauth&user_id=#{user_id}"        
    pages:
        jade:
            target_file: main.target_dir + main.autogen_prefix + '.jade'
            indent: 1
            format: (name, block) ->     """template(name="#{name}")\n#{block}\n\n"""
        stylus:
            target_file: main.late_target_dir + main.autogen_prefix + '_behind.css'
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
}.init()