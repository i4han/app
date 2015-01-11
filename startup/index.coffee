


layout: 
    jade: -> slice "+navbar|#wrapper|>+sidebar|#content-wrapper|>.container-fluid|>+yield|<<<+footer"
    styl: -> slice "body|>background-color #ccc"

home:
    label: 'Home',  router: path: '/'  
    jade: -> slice ".row|>.col-md-8|>h1 #{@C.title} is title|<<.row#items|>.col-md-12#pack|>each items|>+item"
    rendered: ->
        $items = $('#items')
        $('#pack').masonry itemSelector: '.item', columnWidth: 126
    helpers: items: -> db.Items.find {}, sort: created_time: -1
    styl: -> slice '''#items .item|>background-color white |width 240px |height 240px ~
        |float left  |border 1px  |margin 6px'''

item: jade: ".item(style='height:{{height}}px;color:{{color}}')"
    
event:
    label: 'Event',  router: {}
    jade: -> slice ".row|>#container-calendar|>#top|#items|#bottom"
    rendered: -> calendar moment().format('YYYYMM'), $('#items'), 'tile'
    styl: -> slice '''#container-calendar|>max-width 1180px ~
        |<.tile|>width 160px|height 160px|float left|border 1px|background-color white|margin 2px ~
        |<h2|>color black'''

#day:
#    jade: -> slice ".tile#day-20141203"

profile:
    label: 'Profile',   sidebar: 'sidebar_profile',   router: {}
    jade: -> slice ".row|>.col-sm-7|>h2 Edit your profile|+br(height='28px')|each items|>+form|br"
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
    jade: -> slice ".row|>.h2 Debug|<.row#help"
    rendered: -> $help = $ '#help'

footer: 
    jade: -> slice ".footer|>.content|>.row|>center © Business 2015"
    styl: -> slice ".footer|>background-color #d9d9d9|padding-top 50px|padding-bottom 20px"


            
