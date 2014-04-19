if !Meteor?
    stylus = require 'stylus'

main =
    title:            'App'
    home_url:         'http://www.hi16.ca'
    home_dir:         '/home/action/workspace/app/'
    callback_port: 3003

module.exports.__config__ = {
    title:             main.title
    home_url:          main.home_url
    home_dir:          main.home_dir
    callback_port:     main.callback_port
    style_file:        main.home_dir + 'client/hot.style'
    css_file:          main.home_dir + 'main.css'
    log_file:          '/home/action/meteor.log'
    storables:         main.home_dir + 'private/storables'
    set_prefix:        'set_'
    sets:              'content dialog form layout login style' .split ' '
    indent_string:     '    '
    init: ->
        # if !Meteor? sets = ls of set_* in home/lib (*) part.
        this.templates  = Object.keys this.pages
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
        redirect_uri:  ( user_id ) -> 
            "http://www.hi16.ca:3003/callback/instagram/?command=oauth&user_id=#{user_id}"        
    pages:
        jade:
            target_file: main.home_dir + 'client/lib/__generated.jade'
            indent: 1
            format: (name, block) ->     "template(name=\"#{name}\")\n#{block}\n\n"
        stylus:
            target_file: main.home_dir + 'main.css'
            indent: 0
            format: (name, block) -> stylus( block ).render() + '\n'
        HTML:
            target_file: main.home_dir + 'client/lib/__generated.html'
            indent: 1
            format: (name, block) ->     "<template name=\"#{name}\">\n#{block}\n</template>"
        head:
            target_file: main.home_dir + 'client/lib/__gen_head.jade'
            indent: 1
            header: 'head\n'
            format: (name, block) -> block
        less:
            target_file: main.home_dir + 'client/lib/__generated.less'
            indent: 0
            format: (name, block) -> block
        css:
            target_file: main.home_dir + 'client/lib/__generated.css'
            indent: 0
            format: (name, block) -> block
        styl:
            target_file: main.home_dir + 'client/lib/__generated.styl'
            indent: 0
            format: (name, block) -> block
}.init()