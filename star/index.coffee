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

ø = ''
YM = 'YYYYMM'

scrollspyEvents =
    enter:
        top: ->
            month_year = moment($('#top').next().children().first().attr('id'),YM).subtract(1, 'month').format(YM)
            console.log 'top', month_year
            $('#items').prepend("<div class=month id=#{month_year}></div>")
            $('html, body').animate({ scrollTop: 500 }, 0)
            calendar month_year, $('#'+month_year), 'tile'
            ['title','event'].forEach (s) -> $('.' + s).attr('contenteditable', 'true')
        bottom: ->
            month_year = moment($('#bottom').prev().children().last().attr('id'),YM).add(1, 'month').format(YM)
            console.log 'bottom', month_year
            $('#items').append("<div class=month id=#{month_year}></div>")
            calendar month_year, $('#'+month_year), 'tile'
            ['title','event'].forEach (s) -> $('.' + s).attr('contenteditable', 'true')


calendar = (month_year, jquery, class_str) ->

    jquery.append HTML.toHTML HTML.H2 id:month_year, moment(month_year, YM).format('MMMM YYYY')    
    [1..parseInt(moment(month_year, YM).startOf('month').format 'd')].forEach (i) ->
        jquery.append HTML.toHTML HTML.DIV class:class_str + ' empty'
    $('.empty').css 'visibility', 'hidden' 
    [1..parseInt(moment(month_year, YM).endOf('month').format 'D')].forEach (i) ->        
        id = 'day-' + (day_id = month_year + (DD = ('0' + i.toString()).substr -2, 2))
        console.log 'id', id
        jquery.append HTML.toHTML HTML.DIV id:id, class:class_str, ø
        __.insertTemplate 'day', id, {date_str:day_id}
        contentEditable(id)
        eventListener()

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
            scrollspy scrollspyEvents
            month_year = moment().format(YM)
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

            
