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

            
