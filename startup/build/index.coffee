calendar = (month_year, jquery, class_str) ->
    ø = HTML
    jquery.append ø.toHTML ø.H2 moment(month_year, 'YYYYMM').format('MMMM YYYY')
    [1...parseInt(moment(month_year, 'YYYYMM').startOf('month').format 'd')].forEach (i) ->
        jquery.append ø.toHTML ø.DIV class:class_str + ' empty'
    $('.empty').css 'visibility', 'hidden' 
    [1..parseInt(moment(month_year, 'YYYYMM').endOf('month').format 'D')].forEach (i) ->
        jquery.append ø.toHTML ø.DIV id:"day-#{month_year}#{i}", class:class_str, ø.P "#{i}" 

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
    
    
                
    