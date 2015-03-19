#!/usr/bin/env coffee

String::toDash = -> @.replace /([A-Z])/g, ($1) -> '-' + $1.toLowerCase()

extend = ($source, $target) ->
    ('display float resize margin padding'.split ' ')
    .concat('color backgroundColor border'.split ' ').forEach (a) ->          
        $target.css(a, $source.css(a)) if $source.css(a)

position = (obj) ->
    Meteor.setTimeout ->
        $('#'+obj.parentId+' .'+obj.class).css top:obj.top, left:obj.left, position:'absolute'
    , 200

repcode = -> ('ᛡ* ᐩ+ ᐟ/ ǂ# ꓸ. ꓹ, ـ- ᚚ= ꓽ: ꓼ; ˈ\' ᐦ" ᐸ< ᐳ> ʿ( ʾ) ʻ{ ʼ}'.split ' ').reduce ((o,v) -> o[v[1..]]=///#{v[0]}///g; o), {' ':/ˌ/g}

parseValue = (value) ->
    if      'number'   == typeof value then value.toString() + 'px'
    else if 'string'   == typeof value then (value = value.replace v,k for k,v of repcode()).pop()
    else if 'function' == typeof value then value() else value

o = (obj, depth=1) -> 
    ((Object.keys obj).map (key) ->
        value = obj[key]
        key = key.replace v,k for k,v of repcode()
        key = key.toDash()
        (Array(depth).join '    ') + 
        if  'object' == typeof value then [key, o(value, depth + 1)].join '\n'
        else if '' is value          then key
        else key + ' ' + parseValue value
    ).join '\n'

o_list = (what) -> # add id
    ((what = if 'string' == typeof what then what.split ' ' 
    else if Array.isArray(what) then what else [])
        .map (a) -> ".#{a} {{#{a}}}").join '\n'

contentEditable = (id, func) ->
    $cloned = undefined
    $('#' + id)
        .on 'focus', '[contenteditable]', -> $(@).data 'before', $(@).html() ; $(@)
        .on 'blur keyup paste input', '[contenteditable]', ->
            $(@).data 'before', $(@).html()
            if $(@).data('before') isnt $(@).html()
                console.log 'edited'
                func(@)
            $(@)
        .on 'scroll', '[contenteditable]', (event) ->
            $(@).scrollTop 0
            event.preventDefault()
            false
        .on 'keydown', '[contenteditable]', ->
            if !$cloned
                zIndex = $(@).css 'z-index'
                $(@).css 'z-index': zIndex = 10 if parseInt(zIndex, 10) == NaN             
                $cloned = $(@).clone()
                $cloned.css
                    'z-index': zIndex-1
                    position: 'absolute'
                    top:      $(@).offset().top
                    left:     $(@).offset().left
                    overflow: 'hidden'
                    outline:  'auto 5px -webkit-focus-ring-color'
                $(@).before $cloned
            else
                $cloned.html $(@).html()
            console.log $cloned.css opacity: 1
            console.log $(@).css overflow:'visible', opacity: 0
            Meteor.setTimeout =>
                $(@).css overflow:'hidden', opacity: 1
                $cloned.css opacity: 0
            ,
                200

window? and ('DIV H2 BR'.split ' ').map (a) -> window[a] = (obj, str) -> 
    if str? then HTML.toHTML HTML[a] obj, str else HTML.toHTML HTML[a] obj

scrollSpy = (obj) ->
    $$ = $ '.scrollspy'
    $$.scrollSpy()
    ['enter', 'exit'].forEach (a) ->
        $$.on 'scrollSpy:' + a, -> obj[a][$(@).attr 'id']() if obj[a]?


slice = (str) -> @_.slice str

sidebar = (list, id='sidebar_menu') ->
    list: list
    jade: -> @_.slice "each items|>+menu_list"
    helpers: 
        items: -> list.map (a) -> { page:a, id:id } # ̵̵̵correct - id must unique.

assignPopover = (o,v) -> 
    o['focus input#'+v] = -> 
        $('input#'+v)
            .attr('data-content', __.render 'popover_'+v)
            .popover 'show' 
    o

popover = (list) -> list.reduce ((o, v) -> assignPopover o, v), {}
#

ø = ''
ß = '&nbsp;'
fym = 'YYYYMM'

calendar = (id_ym) ->
    action = if moment().format(fym) > id_ym then 'prepend' else 'append'
    $('#items')[action](DIV class:'month', id:id_ym)
    moment_ym = moment(id_ym, fym)
    top = $(window).scrollTop()

    ($id = $ '#' + id_ym).append H2 id:id_ym, moment_ym.format 'MMMM YYYY'    
    [1..parseInt moment_ym.startOf('month').format 'd'].forEach (i) ->
        $id.append DIV class:'everyday empty', style:'visibility:hidden'
    [1..parseInt moment_ym  .endOf('month').format 'D'].forEach (i) ->        
        $id.append DIV class:'everyday', id:id = id_ym + ('0' + i)[-2..]
        __.insertTemplate 'day', id, id:id
        contentEditable id, (_id) ->
            id = $(_id).parent().attr 'id'
            content = $(_id).html()
            switch $(_id).attr 'class'
                when 'title'
                    console.log 'title', id, content 
                    if doc = db.Calendar.findOne({id:id})
                        db.Calendar.update(_id:doc._id, $set:{title:content, event:doc.event})
                    else 
                        db.Calendar.insert id:id, title:content
                when 'event'
                    console.log 'event', id, content
                    if doc = db.Calendar.findOne({id:id})
                        db.Calendar.update(_id:doc._id, $set:{title:doc.title, event:content})
                    else 
                        db.Calendar.insert id:id, event:content
        ['title','event'].forEach (s) -> $("##{id} > .#{s}").attr 'contenteditable', 'true'
    if 'prepend' is action
        Meteor.setTimeout ( -> $(window).scrollTop( top + $id.outerHeight())), 10
        $('#top'   ).data id:id_ym
    else
        $('#bottom').data id:id_ym

date_box_size = 120
calendar_size = date_box_size * 7 + 14

module.exports.index =

    logo:
        jade: o '#logo': 'instaMek'
        styl: o '#logo': width: 110, float: 'left', padding: 15, fontWeight: '200', fontSize: 15, color: 'white', textAlign: 'right'

    layout: 
        jade: o '+navbar' :'', '#wrapper':'+sidebar':'', '+yield':''
        styl: o body: backgroundColor: '#ddd'
        navbar: sidebar: true, login: true, menu: 'home map calendar vehicle request log help'

    home:
        label: 'Home', sidebar: 'sidebar_home',  router: path: '/'  
        jade: o '#contentWrapper': 
                h1:'Insta'
                '.row#items':'.col-md-12#pack':'each items':'+item':ø
        styl: o '#items .item':backgroundColor:'white', width:240, height:240, float:'left', margin:6
        rendered: -> Meteor.setTimeout (-> $('#pack').masonry itemSelector: '.item', columnWidth: 126), 40
        helpers: items: -> db.Items.find {}, sort: created_time: -1
    sidebar_home: sidebar ['home', 'calendar', 'help']

    item: jade: ".item(style='height:{{height}}px;color:{{color}}')" 

    vehicle:
        label: 'Vehicle', sidebar: 'sidebar_vehicle', router: path: 'vehicle'
        jade: o '#contentWrapper': 
                h1: 'You vehicle information', br: ''
                '.col-sm-7': 'each items': '+form': '', br:''
        helpers: items: -> [
                { label: 'Maker',   id: 'maker',  title: 'Car manufacturer',         icon: 'mobile'     },
                { label: 'Model',   id: 'model',  title:  'Year of the model',       icon: 'mobile'  },
                { label: 'Color', id: 'color',     title: 'Color of your vehicle',   icon: 'mobile' }]
        events: popover 'maker model color' .split ' '
    popover_maker:    jade: o ul:li: 'manufacturer in 20 characters'
    popover_model:   jade: o ul:li: 'For digit'
    popover_color: jade: o ul:li: 'White or black only'
    sidebar_map: sidebar 'home map calendar request vehicle log help'.split ' '             


    map:
        label: 'Map', sidebar: 'sidebar_map', router: path: 'map'
        jade: '#map-canvas'
        styl: o '#map-canvas': height: '100%', padding: 0, margin: 0
        rendered: ->
            google.maps.event.addDomListener window, 'load', Pages.map.map_init
            Meteor.setTimeout Pages.map.map_init, 10
        map_init: -> 
            new google.maps.Map document.getElementById('map-canvas'), 
                disableDefaultUI: true, zoom: 11, center: lat: 53.52, lng: -113.5
    sidebar_map: sidebar 'home map calendar request vehicle log help'.split ' '             
                
    calendar:
        label: 'Calendar',  router: {}
        jade: o '#contentWrapper':
                '#containerCalendar':'.scrollspy#top':ß, '#items':'', '.scrollspy#bottom':ß
        rendered: -> 
            calendar this_month = moment().format fym
            $('#top').data id:this_month
            scrollSpy enter:
                top:    -> calendar moment($('#top'   ).data('id'), fym).subtract(1, 'month').format fym
                bottom: -> calendar moment($('#bottom').data('id'), fym).add(     1, 'month').format fym
        styl: o 
            '#containerCalendar':width: calendar_size, maxWidth: calendar_size
            h2: color:'black', display:'block' 
            '.everyday': position: 'relative', width:date_box_size, height:date_box_size, float:'left', padding:8, backgroundColor:'white', margin:2           
            '.month':    display:'block', height: calendar_size
            '.spacer':   lineHeight: 10
    log:
        label: 'Log', router: path: 'log'
        jade: '#log-canvas'
        rendered: -> $('#log-canvas').html '<object id="full-screen" data="http://localhost:8778/"/>'
        styl: o 
            '#log-canvas':  height: '100%', width: '100%'
            '#full-screen': height: '100%', width: '100%'

    day:
        collection: 'calendar'
        jade: o_list 'init title date day event'
        helpers:
            date:  -> moment(@id, 'YYYYMMDD').format 'D'
            day:   -> moment(@id, 'YYYYMMDD').format 'ddd'
            title: -> db.Calendar.findOne({id:@id})?['title'] or 'Title'
            event: -> '' #gCal[@id] or ''
            init:  ->
                position parentId:@id, class:'title', top:14,
                position parentId:@id, class:'event', top:45,
                position parentId:@id, class:'date',  top: 5, left:(date_box_size - 35)
                position parentId:@id, class:'day',   top:28, left:(date_box_size - 37)
                ø
        styl: o
            ꓸinit:  display:'none'
            ꓸtitle: display:'inline', fontWeight:'100'               
            ꓸdate:  display:'inline', fontWeight:'600', fontSize:'14pt', width:24, textAlign:'right'
            ꓸday:   display:'table',  fontWeight:'100', float:'right',   width:24, textAlign:'right', color:'#444',  fontSize: '8pt'
            ꓸevent: resize:'none',    fontWeight:'100'
            ꓸrowǂday01: marginBottom:0
    request:
        label: 'Request', router: path: 'request'
        jade: o '#contentWrapper': 
                h1: 'Request a Mek', br: ''
                '.col-sm-7': 'each items': '+form': '', br:''
        helpers: items: -> [
                { label: 'Name',    id: 'name',   title: 'Your name',           icon: 'user'     },
                { label: 'Phone',   id: 'phone',  title:  'Phone Number',       icon: 'mobile'  },
                { label: 'Address', id: 'address',title: 'Your home Zip code',  icon: 'envelope' }]
        events: popover 'name phone address' .split ' '
    popover_name:    jade: o ul:li: 'Write your name.', 'li ': 'No longer then 12 letters.'
    popover_phone:   jade: o ul:li: 'Write your phone number.'
    popover_address: jade: o ul:li: 'Write your zipcode.'

#    jade: -> slice ".row|>.col-sm-7|>h2 Edit your profile|+br(height='32px')|each items|>+form|br"

    help:
        label: 'Help',   router: {}
        jade: o '#contentWrapper':h1:'Help'

            
