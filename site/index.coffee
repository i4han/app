module.exports.index =

    layout:
        jade: (C,_) -> _.cutup "+navbar|#wrapper|>+sidebar|#page-content-wrapper|>.container-fluid|>+yield|<.footer|>+footer"
        head: (Config) -> 
            """
            title #{Config.title}
            link(href="https://fonts.googleapis.com/css?family=PT+Sans:400,700" rel="stylesheet" type="text/css")
            """

    home_sidebar:
        jade: (C,_) -> _.cutup "each items|>+menu_list"
        helpers:    items: -> [
            { page: 'home',    id: 'sidebar_menu' },
            { page: 'help',    id: 'sidebar_menu' },
            { page: 'connect', id: 'sidebar_menu' } ]

    home:
        label: 'Home'
        router: path: '/'
        sidebar: 'home_sidebar'
        jade: (C,_) -> _.cutup ".row|>.col-md-8|>h1 #{C.title}|<<.row#items|>.col-md-8|>each items|>.item|>+item"
        created: -> 
            db.Items = new Meteor.Collection 'items' if !db.Items?
            Meteor.subscribe 'items'
        rendered: ->
            $container = $('#items')
            # $container.masonry itemSelector: '.item', columnWidth: 332
        helpers:
            hello: -> 'world'
            items: -> db.Items.find {}, sort: created_time: -1
        __styl: """
            #items > .item 
                background-color #fff
                width 320px
                height 320px
                float left
                border 1px solid #999
                margin 6px
                transform rotateY( 45deg )
                -webkit-transform rotateY( 45deg )
            """
        
    item:
        jade: """img(src="{{url}}" height="320" width="320")"""
        
    about:
        label: 'About'
        router: {}
        jade: ".row|>+hello|+br(height='36px')|+dialog"
        rendered: ->
            _.each [1..20], (i) -> $container.append( $("""<div id="tile-#{i}" class="tile box"><h2>Tile #{i}</h2></div>""") ) 
            $('.tile').on 'scrollSpy:enter', -> console.log 'enter:', $(this).attr 'id' 
            $('.tile').on 'scrollSpy:exit', -> console.log 'exit:', $(this).attr 'id' 
            $('.tile').scrollSpy()
        __styl: ".tile|>width 160px|float left|border 1px solid #999|margin 6px"

    profile_sidebar:
        jade: (C,_) -> _.cutup "each menu_items|>+menu_list"
        helpers:
            menu_items: -> [
                { page: 'home',    id: 'sidebar_menu' },
                { page: 'help',    id: 'sidebar_menu' },
                { page: 'connect', id: 'sidebar_menu' }]

    profile:
        label: 'Profile'
        sidebar: 'profile_sidebar'
        router: {}
        jade: (C,_) -> _.cutup ".row|>.col-sm-6|>+br(height='36px')|each items|>+form|+br(height='9px')"
        helpers:
            items: -> [
                { title: 'Your name',           label: 'Name',   icon: 'user'     },
                { title: 'Mobile Phone Number', label: 'Mobile', icon: 'mobile'   },
                { title: 'Your home Zip code',  label: 'Zip',    icon: 'envelope' }]
        events:
            'focus input#name':   -> $('input#name')  .attr('data-content',  Template['popover_name'].renderFunction().value).popover('show')
            'focus input#mobile': -> $('input#mobile').attr('data-content',  Template['popover_mobile'].renderFunction().value).popover('show')
            'focus input#zip':    -> $('input#zip')   .attr('data-content',  Template['popover_zip'].renderFunction().value).popover('show')
    popover_name: jade: (C,_) -> _.cutup "ul|>li Write your name.|li No longer then 12 letters."
    popover_mobile: jade: "ul: li Write your phone number."
    popover_zip: jade: "ul: li Write your zipcode."

    help:
        label: 'Help'
        router: {}
        jade: """
            .primary-content
                .h2 Debug..  
            .primary-content#debug
            """
        rendered: ->
            container = $('#debug')
            _.each _.keys( Pages ), ( name ) ->
                container.append( $("<h2>#{name}</h2>") )         
                _.each _.keys( Pages[name] ), ( key ) ->
                    container.append( $("<h3>#{key}</h3><pre>#{Pages[name][key]}</pre>") )

    connect_sidebar:
        jade: "each menu_items\n    +menu_list"
        helpers:
            menu_items: -> [
                { page: 'home',    id: 'sidebar_menu' },
                { page: 'connect',    id: 'sidebar_menu' }]

    connect:
        label: 'Connect'
        router: {}
        sidebar: 'connect_sidebar'
        jade: """
            h2 Connect
            br.single-line
            a(href="{{instagram_connect}}") 
                | Connect with Instagram
            input.btn.btn-default(type="button" value="Click")
            """
        helpers:
            instagram_connect: -> Config.instagram.oauth_url + '?' + __.queryString
                client_id: Config.instagram.client_id
                redirect_uri: Config.instagram.redirect_uri Meteor.userId()
                response_type: Config.instagram.response_type

        events:
            'click input': -> console.log Router.current().route.name

    footer:
        jade: """
            .content
                .row    
                    +br(height='54px')
                    center © Businesses 2014
            """
                
