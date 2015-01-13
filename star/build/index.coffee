#!/usr/bin/env coffee


repcode = -> ('ᛡ* ᐩ+ ǂ# ꓸ. , ـ- ᚚ= ꓽ: ꓼ; ˈ\' ˮ" ʿ( ʾ) ʻ{ ʼ}'.split ' ').reduce ((o,v) -> o[v[1..]]=///#{v[0]}///g; o), {' ':/ˌ/g}

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

slice = (str) -> @_.slice str

sidebar = (list, id='sidebar_menu') ->
    jade: -> @_.slice "each items|>+menu_list"
    helpers: 
        items: -> list.map (a) -> { page:a, id:id } # correct - id must unique.

assignPopover = (o,v) -> 
    o['focus input#'+v] = -> 
        $('input#'+v)
            .attr('data-content', __.render 'popover_'+v)
            .popover 'show' 
    o

popover = (list) -> list.reduce ((o, v) -> assignPopover o, v), {}
#
eventListener = ->
    $('.tile').on 'change', (obj, class_, id, content) ->
        console.log 'Listener', class_, id, content
        if 'title' == class_
            console.log 'title', db.Title.find({id:id})
            if db.Title.find({id:id}) then db.Title.update(id:id, $set:{content: content})
            else db.Title.insert(id:id, content:content)
        else if 'event' == class_
            console.log 'event', db.Event.find({id:id})
            if db.Event.find({id:id}) then db.Event.update({id:id, $set:{content: content}})
            else db.Event.insert({id:id, content:content})

contentEditable = (id) ->
    $('#' + id)
        .on 'focus', '[contenteditable]', -> $(@).data 'before', $(@).html() ; $(@)
        .on 'blur keyup paste input', '[contenteditable]', ->
            if $(@).data('before') isnt $(@).html()
                $(@).data 'before', $(@).html()
                console.log 'Editable', $this.parent(), class_, id, content 
                id = $(@).parent().attr('id')
                content = $(@).html()
                class_ = $(@).attr('class')
                $(@).parent().trigger('change', [class_, id, content] )
            $(@)

calendar = (month_year, jquery, class_str) ->
    ø = HTML
    jquery.append ø.toHTML ø.H2 id:month_year, moment(month_year, 'YYYYMM').format('MMMM YYYY')    
    [1..parseInt(moment(month_year, 'YYYYMM').startOf('month').format 'd')].forEach (i) ->
        jquery.append ø.toHTML ø.DIV class:class_str + ' empty'
    $('.empty').css 'visibility', 'hidden' 
    [1..parseInt(moment(month_year, 'YYYYMM').endOf('month').format 'D')].forEach (i) ->        
        id = 'day-' + (YYYYMMDD = month_year + (DD = ('0' + i.toString()).substr -2, 2))
        console.log 'id', id
        jquery.append ø.toHTML ø.DIV id:id, class:class_str, ''
        __.insertTemplate 'day', id, {date_str:YYYYMMDD}
        contentEditable(id)
        eventListener()

module.exports.index =

    layout: 
        jade: ᛡ ᐩnavbar:'', ǂwrapper: {ǂcontentـwrapper: ꓸcontainerـfluid: ᐩyield:''}, ᐩfooter:''
        styl: ᛡ body: backgroundـcolor: '#ccc'
        navbar: sidebar: true, login: true, menu: 'home calendar help'.split ' '

    home:
        label: 'Home',  router: path: '/'  
        jade: ᛡ ꓸrow:{ꓸcolـmdـ8:h1:'Event Calendar'},ꓸrowǂitems:ꓸcolـmdـ12ǂpack:eachˌitems:ᐩitem:''
        styl: ᛡ ǂitemsˌꓸitem:{backgroundـcolor:'white', width:240, height:240, float:'left', border:1, margin:6}
        rendered: -> $('#pack').masonry itemSelector: '.item', columnWidth: 126
        helpers: items: -> db.Items.find {}, sort: created_time: -1

    item: jade: ᛡ ꓸitemʿstyleᚚˈheightꓽʻʻheightʼʼpxꓼcolorꓽʻʻcolorʼʼˈʾ:''
        
    calendar:
        label: 'Calendar',  router: {}
        jade: ᛡ ꓸrow:ǂcontainerـcalendar:{ꓸscrollspyǂtop:'top', ǂitems:'', ꓸscrollspyǂbottom:'bottom'}
        rendered: ->
            $scrollspy = $('.scrollspy')
            $scrollspy.scrollSpy()
            $scrollspy.on 'scrollSpy:enter', -> 
                if 'top' == $(@).attr 'id'
                    month_year = moment($('#top').next().children().first().attr('id'),'YYYYMM').subtract(1, 'month').format('YYYYMM')
                    console.log 'top', month_year
                    $('#items').prepend("<div class=month id=#{month_year}></div>")
                    $('html, body').animate({ scrollTop: 500 }, 0)
                    calendar month_year, $('#'+month_year), 'tile'
                    $('.title').attr('contenteditable', 'true')
                    $('.event').attr('contenteditable', 'true')

                else if 'bottom' == $(@).attr 'id'
                    month_year = moment($('#bottom').prev().children().last().attr('id'),'YYYYMM').add(1, 'month').format('YYYYMM')
                    console.log 'bottom', month_year
                    $('#items').append("<div class=month id=#{month_year}></div>")
                    calendar month_year, $('#'+month_year), 'tile'
                    $('.title').attr('contenteditable', 'true')
                    $('.event').attr('contenteditable', 'true')
            month_year = moment().format('YYYYMM')
            $('#items').append("<div class=month id=#{month_year}></div>")
            calendar month_year, $('#'+month_year), 'tile'
            $('.title').attr('contenteditable', 'true')
            $('.event').attr('contenteditable', 'true')
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
            title: -> db.Title.find({id:@id})
            event: -> db.Event.find({id:@id})
        styl: ᛡ
            ꓸdate:  {display:'inline', marginـright:10, fontـweight:'600'}
            ꓸday:   {display:'inline', marginـright:10}
            ꓸtitle: {display:'inline'}
            ꓸevent: {marginـtop:10, marginـleft:5}

    help:
        label: 'Help',   router: {}
        jade: ᛡ ꓸrow:h1:'Help',ꓸrowǂhelp:''
        rendered: -> $help = $ '#help'

    footer: 
        jade: ᛡ ꓸfooter:ꓸcontent:ꓸrow:center:'© 2009 - 2014 Startup Edmonton ❘ 301 - 10359 104 Street, Edmonton, Alberta T5J 1B9 ❘ hello@startupedmonton.com'
        styl: ᛡ ꓸfooter:{backgroundـcolor:'#ddd',paddingـtop:50,paddingـbottom:20}

            
