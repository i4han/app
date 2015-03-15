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

date_box_size = 140
calendar_size = date_box_size * 7 + 14

module.exports.index =

    layout: 
        jade: o 
            '+navbar' :ø
            '#wrapper':'+sidebar':ø, '#contentWrapper': '.containerFluid': '+yield':ø, '+footer':ø
        styl: o 
            body: backgroundColor: '#ddd'
            '#content-wrapper': padding: 0
            '.container-fluid': padding: 0
        navbar: sidebar: true, login: true, menu: 'home map test calendar log help'

    home:
        label: 'Home', sidebar: 'sidebar_home',  router: path: '/'  
        jade: o 
            '.row':'.col-md-8':h1:'Event Calendar'
            '.row#items':'.col-md-12#pack':'each items':'+item':ø
        styl: o '#items .item':backgroundColor:'white', width:240, height:240, float:'left', margin:6
        rendered: -> $('#pack').masonry itemSelector: '.item', columnWidth: 126
        helpers: items: -> db.Items.find {}, sort: created_time: -1
    sidebar_home: sidebar ['home', 'calendar', 'help']

    test: 
        label: 'Test', sidebar: 'sidebar_test', router: path: 'test'
        jade: o '.row': h1: 'Test'
    sidebar_test: sidebar ['calendar', 'help']

    item: jade: ".item(style='height:{{height}}px;color:{{color}}')" 

    map:
        label: 'Map', router: path: 'map'
        jade: o '#map-canvas': ø
        rendered: ->
            ('html body #wrapper #content-wrapper .container-fluid #map-canvas'.split ' ').map (a) ->
                $(a).height '100%'
            google.maps.event.addDomListener window, 'load', Pages.map.map_init
            Meteor.setTimeout Pages.map.map_init, 200
        map_init: -> 
            new google.maps.Map document.getElementById('map-canvas'), 
                center: lat: 53.43, lng: -113.5
                zoom: 11
                disableDefaultUI: true
    calendar:
        label: 'Calendar',  router: {}
        jade: o ꓸrow:ǂcontainerCalendar:ꓸscrollspyǂtop:ß, ǂitems:ø, ꓸscrollspyǂbottom:ß
        rendered: -> 
            calendar this_month = moment().format fym
            $('#top').data id:this_month
            scrollSpy enter:
                top:    -> calendar moment($('#top'   ).data('id'), fym).subtract(1, 'month').format fym
                bottom: -> calendar moment($('#bottom').data('id'), fym).add(     1, 'month').format fym
        styl: o 
            ǂcontainerCalendar:width: calendar_size, maxWidth: calendar_size
            h2:   color:'black', display:'block' 
            ꓸeveryday: position: 'relative', width:date_box_size, height:date_box_size, float:'left', padding:8, backgroundColor:'white', margin:2           
            ꓸmonth:    display:'block', height: calendar_size
            ꓸspacer:   lineHeight: 10
    log:
        label: 'Log', router: path: 'log'
        jade: o '#canvas': ø
        rendered: -> $('#canvas').html '<object id="full" data="http://localhost:8778/"/>'
        styl: o 
            '#canvas': height: '100%', width: '100%'
            '#full': height: '100%', width: '100%'

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
    help:
        label: 'Help',   router: {}
        jade: o ꓸrow:h1:'Help',ꓸrowǂhelp:ø

    footer: 
        jade: o ꓸfooter:ꓸcontent:ꓸrow:center:'© 2009 - 2015 Startup Edmonton ❘ 301 - 10359 104 Street, Edmonton, Alberta T5J 1B9 ❘ hello@startupedmonton.com'
        styl: o ꓸfooter:backgroundColor:'#ddd', paddingTop:50, paddingBottom:20

            
