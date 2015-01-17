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

            
