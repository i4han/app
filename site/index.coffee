slice = (str) -> @_.slice str
sidebarMenu = (list, id='sidebar_menu') ->
    jade: -> @_.slice "each items|>+menu_list"
    helpers: items: -> list.map (a) -> { page:a, id:id } # correct - id must unique.
popover = (list) ->
    list.reduce ((o,v) -> 
        ( o['focus input#'+v] = -> $('input#'+v).attr('data-content', __.render 'popover_'+v).popover('show') ) ; o ), {}

module.exports.index =

    layout: jade: -> 
        slice "+navbar|#wrapper|>+sidebar|#content-wrapper|>.container-fluid|>+yield|<<<+footer"

    home:
        label: 'Home',   sidebar: 'sidebar_home',   router: path: '/'  
        jade: -> slice ".row|>.col-md-8|>h1 #{@C.title} is title|<<.row#items|>.col-md-8|>each items|>.item|>+item"
        rendered: ->
            $items = $('#items')
            # $container.masonry itemSelector: '.item', columnWidth: 332
        helpers: items: -> db.Items.find {}, sort: created_time: -1
        styl: -> slice '''#items .item|>background-color #eee |width 320px |height 320px ~
            |float left |border 1px   |margin 6px ~
            |transform rotateY(45deg) |-webkit-transform rotateY(45deg)'''

    item: jade: "img(height='320' width='320')"
        
    about:
        label: 'About', router: {}
        jade: ".row#items" # ".row|>+hello|+br(height='36px')|+dialog"
        rendered: ->
            $items = $ '#items'
            $('body').scrollspy({ target: '#items' })
            [1..21].forEach (i) -> 
                $items.append HTML.toHTML HTML.DIV id:"tile-#{i}", class:'tile box', HTML.P "Tile #{i}" 
            $tile = $('.tile')
            $items.on 'activate.bs.scrollspy', -> console.log 'enter:', $(this).attr 'id' 
            $tile.on 'scrollSpy:exit', -> console.log 'exit:', $(this).attr 'id' 
        styl: -> slice ".tile|>width 160px|height 160px|float left|border 1px|background-color white|margin 1px"


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
            |a(href='{{instagram_connect}}') Connect with Instagram|+br(height='48px') ~
            |input.btn.btn-default(type='button' value='Click')'''
        helpers:
            instagram_connect: -> Config.instagram.oauth_url + '?' + __.queryString
                client_id: Config.instagram.client_id
                redirect_uri: Config.instagram.redirect_uri Meteor.userId()
                response_type: Config.instagram.response_type
        events: 'click input': -> console.log Router.current().route.name

    sidebar_home:    sidebarMenu 'home about connect help' .split ' '
    sidebar_profile: sidebarMenu 'home about help' .split ' '
    sidebar_connect: sidebarMenu 'home connect help' .split ' '

    footer: 
        jade: -> slice ".footer|>.content|>.row|>center © Business 2015"
        styl: -> slice ".footer|>background-color #d9d9d9|padding-top 50px|padding-bottom 20px"
                
