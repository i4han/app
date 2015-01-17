#!/usr/bin/env coffee


repcode = -> ('ᛡ* ᐩ+ ᐟ/ ǂ# ꓸ. ꓹ, ـ- ᚚ= ꓽ: ꓼ; ˈ\' ᐦ" ᐸ< ᐳ> ʿ( ʾ) ʻ{ ʼ}'.split ' ').reduce ((o,v) -> o[v[1..]]=///#{v[0]}///g; o), {' ':/ˌ/g}

parseValue = (value) ->
    if      'number'   == typeof value then value.toString() + 'px'
    else if 'string'   == typeof value then (value = value.replace v,k for k,v of repcode()).pop()
    else if 'function' == typeof value then value() else value

ᛡ = (obj, depth=1) -> 
    ((Object.keys obj).map (key) ->
        value = obj[key]
        key = key.replace v,k for k,v of repcode()
        (Array(depth).join '    ') + 
        if  'object' == typeof value then [key, ᛡ(value, depth + 1)].join '\n'
        else if '' is value          then key
        else key + ' ' + parseValue value
    ).join '\n'

ᛡlist = (what) -> # add id
    ((what = if 'string' == typeof what then what.split ' ' 
    else if Array.isArray(what) then what else [])
        .map (a) -> ".#{a} {{#{a}}}").join '\n'

contentEditable = (id, func) ->
    $('#' + id)
        .on 'focus', '[contenteditable]', -> $(@).data 'before', $(@).html() ; $(@)
        .on 'blur keyup paste input', '[contenteditable]', ->
            console.log $(@).data 'before', $(@).html()
            if $(@).data('before') isnt $(@).html()
                console.log 'edited'
                func(@)
            $(@)

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
            month_year = moment($('#top').next().children().first().attr('id'),format_YM).subtract(1, 'month').format(format_YM)
            $('#items').prepend("<div class=month id=#{month_year}></div>")
            $('html, body').animate({ scrollTop: 500 }, 0)
            calendar month_year, $('#'+month_year), 'tile'
            ['title','event'].forEach (s) -> $('.' + s).attr('contenteditable', 'true')
        bottom: ->
            month_year = moment($('#bottom').prev().children().last().attr('id'),format_YM).add(1, 'month').format(format_YM)
            $('#items').append("<div class=month id=#{month_year}></div>")
            calendar month_year, $('#'+month_year), 'tile'
            ['title','event'].forEach (s) -> $('.' + s).attr('contenteditable', 'true')

edited = (_id) ->
    id = $(_id).parent().attr('id')
    content = $(_id).html()
    class_ = $(_id).attr('class')
    console.log 'edited', id, content
    if 'title' == class_
        console.log 'title', db.Title.find({id:id})
        if db.Title.find({id:id}) then db.Title.update(id:id, $set:{content: content})
        else db.Title.insert(id:id, content:content)
    else if 'event' == class_
        console.log 'event', db.Event.find({id:id})
        if db.Event.find({id:id}) then db.Event.update({id:id, $set:{content: content}})
        else db.Event.insert({id:id, content:content})

calendar = (month_year, $id, class_str) ->

    $id.append H2 id:month_year, moment(month_year, format_YM).format('MMMM YYYY')    
    [1..parseInt(moment(month_year, format_YM).startOf('month').format 'd')].forEach (i) ->
        $id.append DIV class:class_str + ' empty', style:'visibility:hidden'
#    $('.empty').css 'visibility', 'hidden' 
    [1..parseInt(moment(month_year, format_YM).endOf('month').format 'D')].forEach (i) ->        
        id = 'day-' + (day_id = month_year + (DD = ('0' + i.toString()).substr -2, 2))
        $id.append DIV id:id, class:class_str, ø
        __.insertTemplate 'day', id, {date_str:day_id}
        contentEditable(id, edited)

module.exports.index =

    layout: 
        jade: ᛡ ᐩnavbar:ø, ǂwrapper: {ǂcontentـwrapper: ꓸcontainerـfluid: ᐩyield:ø}, ᐩfooter:ø
        styl: ᛡ body: backgroundـcolor: '#ccc'
        navbar: sidebar: true, login: true, menu: 'home calendar help'

    home:
        label: 'Home',  router: path: '/'  
        jade: ᛡ ꓸrow:{ꓸcolـmdـ8:h1:'Event Calendar'},ꓸrowǂitems:ꓸcolـmdـ12ǂpack:eachˌitems:ᐩitem:ø
        styl: ᛡ ǂitemsˌꓸitem:{backgroundـcolor:'white', width:240, height:240, float:'left', border:1, margin:6}
        rendered: -> $('#pack').masonry itemSelector: '.item', columnWidth: 126
        helpers: items: -> db.Items.find {}, sort: created_time: -1

    item: jade: ".item(style='height:{{height}}px;color:{{color}}')" # ᛡ ꓸitemʿstyleᚚˈheightꓽʻʻheightʼʼpxꓼcolorꓽʻʻcolorʼʼˈʾ:'' # 
        
    calendar:
        label: 'Calendar',  router: {}
        jade: ᛡ ꓸrow:ǂcontainerـcalendar:{ꓸscrollspyǂtop:'top', ǂitems:ø, ꓸscrollspyǂbottom:'bottom'}
        rendered: -> 
            scrollSpy scrollspyEvents
            month_year = moment().format(format_YM)
            $('#items').append("<div class=month id=#{month_year}></div>")
            calendar month_year, $('#'+month_year), 'tile'
            ['title','event'].forEach (s) -> $('.' + s).attr('contenteditable', 'true')
        styl: ᛡ 
            h2:{color:'black',marginـtop:1000,display:'block'} 
            ǂcontainerـcalendar:{width: 1180, maxـwidth: 1180}
            ꓸtile:{width:160,height:160,float:'left',padding:8,border:1,backgroundـcolor:'white',margin:2}            
            ꓸbreak:{display:'block',height:160,width:1},ꓸmonth:display:'block'
    day:
        jade: ᛡlist 'date day title event'
        helpers:
            date: -> moment(@date_str, 'YYYYMMDD').format('D')
            day:  -> moment(@date_str, 'YYYYMMDD').format('ddd')
            title: -> db.Title.find({id:@id}) ; 'Title'
            event: -> db.Event.find({id:@id}) ; 'Event'
        styl: ᛡ
            ꓸdate:  {display:'inline', marginـright:10, fontـweight:'600'}
            ꓸday:   {display:'inline', marginـright:10}
            ꓸtitle: {display:'inline'}
            ꓸevent: {marginـtop:10, marginـleft:5}

    help:
        label: 'Help',   router: {}
        jade: ᛡ ꓸrow:h1:'Help',ꓸrowǂhelp:ø
        rendered: -> $help = $ '#help'

    footer: 
        jade: ᛡ ꓸfooter:ꓸcontent:ꓸrow:center:'© 2009 - 2014 Startup Edmonton ❘ 301 - 10359 104 Street, Edmonton, Alberta T5J 1B9 ❘ hello@startupedmonton.com'
        styl: ᛡ ꓸfooter:{backgroundـcolor:'#ddd',paddingـtop:50,paddingـbottom:20}

            
