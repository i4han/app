
slice = (str) -> @_.slice str

# correct - id must unique.
sidebar = (list, id='sidebar_menu') ->
    jade: -> @_.slice "each items|>+menu_list"
    helpers: 
    	items: -> list.map (a) -> { page:a, id:id } 

assignPopover = (o,v) -> 
    o['focus input#'+v] = -> 
        $('input#'+v)
            .attr('data-content', __.render 'popover_'+v)
            .popover 'show' 
    o

popover = (list) -> list.reduce ((o, v) -> assignPopover o, v), {}

module.exports.index =
    layout: 
        jade: -> slice "+navbar|#wrapper|>+sidebar|#content-wrapper|>.container-fluid|>+yield|<<<+footer"
        styl: -> slice "body|>background-color #ccc"
    
    home:
        label: 'Home',   sidebar: 'sidebar_home',   router: path: '/'  
        jade: -> slice ".row|>.col-md-8|>h1 #{@C.title} is title|<<.row#items|>.col-md-12#pack|>each items|>+item"
        rendered: ->
            $items = $('#items')
            $('#pack').masonry itemSelector: '.item', columnWidth: 126
        helpers: items: -> db.Items.find {}, sort: created_time: -1
        styl: -> slice '''#items .item|>background-color white |width 240px |height 240px ~
            |float left  |border 1px  |margin 6px'''
    
    item: jade: ".item(style='height:{{height}}px;color:{{color}}')"
        
    about:
        label: 'About', router: {}
        jade: ".row#items"
        rendered: ->
            $items = $ '#items'
            $('body').scrollspy({ target: '#items' })
            [1..21].forEach (i) -> 
                $items.append HTML.toHTML HTML.DIV id:"tile-#{i}", class:'tile box', HTML.P "Tile #{i}" 
            $tile = $('.tile')
            $items.on 'activate.bs.scrollspy', -> console.log 'enter:', $(this).attr 'id' 
            $tile.on 'scrollSpy:exit', -> console.log 'exit:', $(this).attr 'id' 
        styl: -> slice ".tile|>width 160px|height 160px|float left|border 1px|background-color white|margin 1px"
    
    sidebar_home:     sidebar 'home about connect help' .split ' '
    sidebar_profile:  sidebar 'home about help' .split ' '
    sidebar_connect:  sidebar 'home connect help' .split ' '
        
    profile:
        label: 'Profile',   sidebar: 'sidebar_profile',   router: {}
        jade: -> slice ".row|>.col-sm-7|>h2 Edit your profile|+br(height='32px')|each items|>+form|br"
        helpers: items: -> [
                { label: 'Name',   id: 'name',   title: 'Your name',           icon: 'user'     },
                { label: 'Mobile', id: 'mobile', title: 'Mobile Phone Number', icon: 'mobile'   },
                { label: 'Zip',    id: 'zip',    title: 'Your home Zip code',  icon: 'envelope' }]
        events: popover 'name mobile zip' .split ' '
    popover_name:   jade: -> slice "ul|>li Write your name.|li No longer then 12 letters."
    popover_mobile: jade: "ul: li Write your phone number."
    popover_zip:    jade: "ul: li Write your zipcode."
    
    help:
        label: 'Help',   router: {}
        jade: -> slice ".primary-content|>.h2 Debug|<.primary-content#debug"
        rendered: ->
            $debug = $ '#debug'
            (Object.keys Pages).map (name) ->
                $debug.append HTML.toHTML HTML.H2 name         
                (Object.keys Pages[name]).map (key) ->
                    $debug.append HTML.toHTML HTML.H3 key 
                    $debug.append HTML.toHTML HTML.PRE "#{Pages[name][key]}"
    
    connect:
        label: 'Connect',  sidebar: 'sidebar_connect',  router: {}
        jade: -> slice '''.row|>.col-md-8|h2 Connect|+br(height='48px') ~
            |a(href='{{instagram_connect}}') Connect with Instagram|with h|>+button'''
        helpers:
            h: class:'btn-default', label: 'Click'
            instagram_connect: -> Config.instagram.oauth_url + '?' + __.queryString
                client_id: Config.instagram.client_id
                redirect_uri: Config.instagram.redirect_uri Meteor.userId()
                response_type: Config.instagram.response_type
        events: 'click input': -> console.log Router.current().route.name
    
    footer: 
        jade: -> slice ".footer|>.content|>.row|>center © Business 2015"
        styl: -> slice ".footer|>background-color #d9d9d9|padding-top 50px|padding-bottom 20px"
                
    