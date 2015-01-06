module.exports.index =

    layout:
        jade: (C,_) -> _.cutup "+navbar|#wrapper|>+sidebar|#page-content-wrapper|>.container-fluid|>+yield|<<<+footer"
        head: (C,_) -> _.cutup "title #{C.title}|link(href='#{C._.font_style.pt_sans}' rel='stylesheet')"
        styl: (C,_) -> _.cutup """body|>font-family #{C.$.font_family}|font-weight #{C.$.font_weight} ~
            |background-color #f2f2f2"""
    home_sidebar:
        jade: (C,_) -> _.cutup "each items|>+menu_list"
        helpers: items: -> ['home', 'help', 'connect'].map (a) -> {page:a, id:'sidebar_menu'}

    home:
        label: 'Home',     sidebar: 'home_sidebar',     router: path: '/'  
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
        styl: (C,_) -> _.cutup "#items .item|>background-color #eee|width 320px|height 320px|float left" +
            "|border 1px|solid #999|margin 6px|transform rotateY(45deg)|-webkit-transform rotateY(45deg)"

    item: jade: "img(src='{{url}}' height='320' width='320')"
        
    about:
        label: 'About', router: {}
        jade: (C,_) -> ".row|>+hello|+br(height='36px')|+dialog"
        rendered: ->
            _.each [1..20], (i) -> $container.append( $("""<div id="tile-#{i}" class="tile box"><h2>Tile #{i}</h2></div>""") ) 
            $('.tile').on 'scrollSpy:enter', -> console.log 'enter:', $(this).attr 'id' 
            $('.tile').on 'scrollSpy:exit', -> console.log 'exit:', $(this).attr 'id' 
            $('.tile').scrollSpy()
        __styl: ".tile|>width 160px|float left|border 1px solid #999|margin 6px"

    profile_sidebar:
        jade: (C,_) -> _.cutup "each items|>+menu_list"
        helpers: items: -> ['home', 'help', 'connect'].map (a) -> {page:a, id:'sidebar_menu'}

    profile:
        label: 'Profile',   sidebar: 'profile_sidebar',   router: {}
        jade: (C,_) -> _.cutup ".row|>.col-sm-7|>+br(height='30px')|each items|>+form|+br(height='9px')"
        helpers:
            items: -> [
                { title: 'Your name',           label: 'Name',   icon: 'user'     },
                { title: 'Mobile Phone Number', label: 'Mobile', icon: 'mobile'   },
                { title: 'Your home Zip code',  label: 'Zip',    icon: 'envelope' }]
        events: ['name', 'mobile', 'zip'].reduce (o,v) -> 
            ( o['focus input#'+v] = -> $('input#'+v).attr('data-content', __.render 'popover_'+v).popover('show') ) && o
        ,   {}
    popover_name:   jade: (C,_) -> _.cutup "ul|>li Write your name.|li No longer then 12 letters."
    popover_mobile: jade: (C,_) -> _.cutup "ul: li Write your phone number."
    popover_zip:    jade: (C,_) -> _.cutup "ul: li Write your zipcode."

    help:
        label: 'Help',   router: {}
        jade: (C,_) -> _.cutup ".primary-content|>.h2 Debug|<.primary-content#debug"
        rendered: ->
            container = $('#debug')
            _.each _.keys( Pages ), ( name ) ->
                container.append( $("<h2>#{name}</h2>") )         
                _.each _.keys( Pages[name] ), ( key ) ->
                    container.append( $("<h3>#{key}</h3><pre>#{Pages[name][key]}</pre>") )

    connect_sidebar:
        jade: "each items\n    +menu_list"
        helpers: items: -> ['home', 'connect'].map (a) -> {page:a, id:'sidebar_menu'}

    connect:
        label: 'Connect',  sidebar: 'connect_sidebar',  router: {}
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

        events: 'click input': -> console.log Router.current().route.name

    footer: 
        jade: (C,_) -> _.cutup ".footer|>.content|>.row|>center © Businesses 2015"
        styl: (C,_) -> _.cutup ".footer|>background-color #d9d9d9|padding-top 50px|padding-bottom 20px"
                
