#

ø = ''
ß = '&nbsp;'
fym = 'YYYYMM'
cal_addr = "https://docs.google.com/a/hi16.ca/presentation/d/1NFwUbKn6GhprK3ctcBA7h54t8SXycOzn8Qpm8rhAZYo/edit#slide=id.g4a9c01842_"
cal_tag =
    '201407':'049',  '201408':'033',  '201409':'041',  '201410':'022',  '201411':'02',   '201412':'014'
    '201501':'057',  '201502':'065',  '201503':'073',  '201504':'081',  '201505':'089',  '201506':'097'
    '201507':'0105', '201508':'0113', '201509':'0121', '201510':'0129'

gCal = {}

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

module.exports.index =

    layout: 
        jade: o 
            ᐩnavbar:ø
            ǂwrapper: ǂcontentWrapper: ꓸcontainerFluid: ᐩyield:ø
            ᐩfooter:ø
        styl: o body: backgroundColor: '#ddd'
        navbar: sidebar: true, login: true, menu: 'home calendar help'

    home:
        label: 'Home',  router: path: '/'  
        jade: o 
            ꓸrow:ꓸcolـmdـ8:h1:'Event Calendar'
            ꓸrowǂitems:ꓸcolـmdـ12ǂpack:eachˌitems:ᐩitem:ø
        styl: o ǂitemsˌꓸitem:backgroundColor:'white', width:240, height:240, float:'left', margin:6
        rendered: -> $('#pack').masonry itemSelector: '.item', columnWidth: 126
        helpers: items: -> db.Items.find {}, sort: created_time: -1

    item: jade: ".item(style='height:{{height}}px;color:{{color}}')" 
        
    calendar:
        label: 'Calendar',  router: {}
        jade: o ꓸrow:ǂcontainerCalendar:ꓸscrollspyǂtop:ß, ǂitems:ø, ꓸscrollspyǂbottom:ß
        created: ->
            func = (month, tag) ->
                $.get cal_addr + tag, (data) ->
                    (data.match /"[0-9]{1,2}[^0-9a-zA-Z."][^"]*"/g).forEach (str) ->
                        str.replace s, r for r, s of '\n':/\\u000b/, '\n':/\n+/
                        if (a = str.split '\n').length > 1
                            console.log a
                            gCal[month + ('0' + a[0])[-2..]] = (a[1..]).join '\n'
            # func(month, tag) for month, tag of cal_tag

        rendered: -> 
            calendar this_month = moment().format fym
            $('#top').data id:this_month
            scrollSpy enter:
                top:    -> calendar moment($('#top'   ).data('id'), fym).subtract(1, 'month').format fym
                bottom: -> calendar moment($('#bottom').data('id'), fym).add(     1, 'month').format fym
        styl: o 
            ǂcontainerCalendar:width: 1180, maxWidth: 1180
            h2:   color:'black', display:'block' 
            ꓸeveryday: position: 'relative', width:160, height:160, float:'left', padding:8, backgroundColor:'white', margin:2           
            ꓸmonth:    display:'block', height:1180
            ꓸspacer:   lineHeight: 10
    day:
        collection: 'calendar'
        jade: o_list 'init title date day event'
        helpers:
            date:  -> moment(@id, 'YYYYMMDD').format 'D'
            day:   -> moment(@id, 'YYYYMMDD').format 'ddd'
            title: -> db.Calendar.findOne({id:@id})?['title'] or 'Title'
            event: -> gCal[@id] or ''
            init:  ->
                position parentId:@id, class:'title', top:14,
                position parentId:@id, class:'event', top:45,
                position parentId:@id, class:'date',  top: 5, left:(160 - 35)
                position parentId:@id, class:'day',   top:28, left:(160 - 37)
                ø
        styl: o
            ꓸinit:  display:'none'
            ꓸtitle: display:'inline', fontWeight:'100'               
            ꓸdate:  display:'inline', fontWeight:'600', fontSize:'14pt', width:24, textAlign:'right'
            ꓸday:   display:'table',  fontWeight:'100', float:'right', width:24, textAlign:'right', color:'#444',  fontSize: '8pt'
            ꓸevent: resize:'none',    fontWeight:'100'
            ꓸrowǂday01: marginBottom:0

    help:
        label: 'Help',   router: {}
        jade: o ꓸrow:h1:'Help',ꓸrowǂhelp:ø

    footer: 
        jade: o ꓸfooter:ꓸcontent:ꓸrow:center:'© 2009 - 2014 Startup Edmonton ❘ 301 - 10359 104 Street, Edmonton, Alberta T5J 1B9 ❘ hello@startupedmonton.com'
        styl: o ꓸfooter:backgroundColor:'#ddd', paddingTop:50, paddingBottom:20

            
