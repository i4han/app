#!/usr/bin/env coffee

String::toDash = -> @.replace /([A-Z])/g, ($1) -> '-' + $1.toLowerCase()

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
                console.log 'cloned'
            else
                $cloned.html $(@).html()
                console.log 'copied'
            console.log $cloned.css opacity: 1
            console.log $(@).css overflow:'visible', opacity: 0
            Meteor.setTimeout =>
                $(@).css overflow:'hidden', opacity: 1
                $cloned.css opacity: 0
            ,
                200


('DIV H2'.split ' ').forEach (a) ->
    html_scope = {}
    html_scope = window if window?
    html_scope[a] = (obj, str) -> HTML.toHTML HTML[a] obj, str

scrollSpy = (obj) ->
    $scrollspy = $ '.scrollspy'
    $scrollspy.scrollSpy()
    ['enter', 'exit'].forEach (a) ->
        $scrollspy.on 'scrollSpy:' + a, -> obj[a][$(@).attr 'id']() if obj[a]?


slice = (str) -> @_.slice str

sidebar = (list, id='sidebar_menu') ->
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
format_YM = 'YYYYMM'

scrollspyEvents =
    enter:
        top: ->
            month_year = moment($('#top').next().children().first().attr('id'),format_YM).subtract(1, 'month').format format_YM
            $('#items').prepend DIV class:'month', id:month_year
            $('html, body').animate { scrollTop: 500 }, 0
            calendar month_year, 'tile'
            ['title','event'].forEach (s) -> $('.' + s).attr 'contenteditable', 'true'
        bottom: ->
            month_year = moment($('#bottom').prev().children().last().attr('id'),format_YM).add(1, 'month').format format_YM
            $('#items').append DIV class:'month', id:month_year
            calendar month_year, 'tile'
            ['title','event'].forEach (s) -> $('.' + s).attr 'contenteditable', 'true'

edited = (_id) ->
    id = $(_id).parent().attr('id')
    content = $(_id).html()
    switch $(_id).attr('class')
        when 'title'
            console.log 'title', db.Title.find({id:id})
            if db.Title.find({id:id}) then db.Title.update(id:id, $set:{content: content})
            else db.Title.insert(id:id, content:content)
        when 'event'
            console.log 'event', db.Event.find({id:id})
            if db.Event.find({id:id}) then db.Event.update({id:id, $set:{content: content}})
            else db.Event.insert({id:id, content:content})

calendar = (month_year, class_str) ->
    $id = $ '#' + month_year
    $id.append H2 id:month_year, moment(month_year, format_YM).format('MMMM YYYY')    
    [1..parseInt(moment(month_year, format_YM).startOf('month').format 'd')].forEach (i) ->
        $id.append DIV class:class_str + ' empty', style:'visibility:hidden'
    [1..parseInt(moment(month_year, format_YM).endOf('month').format 'D')].forEach (i) ->        
        id = 'day-' + day_id = month_year + ('0' + i.toString()).substr -2, 2
        $id.append DIV class:class_str, id:id
        __.insertTemplate 'day', id, date_str:day_id
        contentEditable id, edited

module.exports.index =

    layout: 
        jade: o 
            ᐩnavbar:ø
            ǂwrapper: ǂcontentWrapper: ꓸcontainerFluid: ᐩyield:ø
            ᐩfooter:ø
        styl: o body: backgroundColor: '#ccc'
        navbar: sidebar: true, login: true, menu: 'home calendar help'

    home:
        label: 'Home',  router: path: '/'  
        jade: o 
            ꓸrow:ꓸcolـmdـ8:h1:'Event Calendar'
            ꓸrowǂitems:ꓸcolـmdـ12ǂpack:eachˌitems:ᐩitem:ø
        styl: o ǂitemsˌꓸitem:backgroundColor:'white', width:240, height:240, float:'left', border:1, margin:6
        rendered: -> $('#pack').masonry itemSelector: '.item', columnWidth: 126
        helpers: items: -> db.Items.find {}, sort: created_time: -1

    item: jade: ".item(style='height:{{height}}px;color:{{color}}')" # ᛡ ꓸitemʿstyleᚚˈheightꓽʻʻheightʼʼpxꓼcolorꓽʻʻcolorʼʼˈʾ:'' # 
        
    calendar:
        label: 'Calendar',  router: {}
        jade: o ꓸrow:ǂcontainerCalendar:ꓸscrollspyǂtop:'top', ǂitems:ø, ꓸscrollspyǂbottom:'bottom'
        rendered: -> 
            scrollSpy scrollspyEvents
            month_year = moment().format format_YM
            $('#items').append DIV class:'month', id:month_year
            calendar month_year, 'tile'
            ['title','event'].forEach (s) -> $('.' + s).attr 'contenteditable', 'true'
        styl: o 
            h2:color:'black', marginTop:1000, display:'block' 
            ǂcontainerCalendar:width: 1180, maxWidth: 1180
            ꓸtile:width:160, height:160, float:'left', padding:8, border:1, backgroundColor:'white', margin:2           
            ꓸbreak:display:'block', height:160, width:1
            ꓸmonth:display:'block'
    day:
        jade: o_list 'date day title event'
        helpers:
            date:  -> moment(@date_str, 'YYYYMMDD').format 'D'
            day:   -> moment(@date_str, 'YYYYMMDD').format 'ddd'
            title: -> db.Title.find({id:@id}) ; 'Title'
            event: -> db.Event.find({id:@id}) ; 'Event'
        styl: o
            ꓸdate:  display:'inline', marginRight:10, fontWeight:'600'
            ꓸday:   display:'inline', marginRight:10
            ꓸtitle: display:'inline'
            ꓸevent: marginTop:10, marginLeft:5

    help:
        label: 'Help',   router: {}
        jade: o ꓸrow:h1:'Help',ꓸrowǂhelp:ø

    footer: 
        jade: o ꓸfooter:ꓸcontent:ꓸrow:center:'© 2009 - 2014 Startup Edmonton ❘ 301 - 10359 104 Street, Edmonton, Alberta T5J 1B9 ❘ hello@startupedmonton.com'
        styl: o ꓸfooter:backgroundColor:'#ddd', paddingTop:50, paddingBottom:20

            
