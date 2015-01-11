


layout: 
    jade: -> slice "+navbar|#wrapper|>#content-wrapper|>.container-fluid|>+yield|<<<+footer"
    styl: -> slice "body|>background-color #ccc"

home:
    label: 'Home',  router: path: '/'  
    jade: -> slice ".row|>.col-md-8|>h1 Event Calendar|<<.row#items|>.col-md-12#pack|>each items|>+item"
    rendered: ->
        $items = $('#items')
        $('#pack').masonry itemSelector: '.item', columnWidth: 126
    helpers: items: -> db.Items.find {}, sort: created_time: -1
    styl: -> slice '''#items .item|>background-color white |width 240px |height 240px ~
        |float left  |border 1px  |margin 6px'''

item: jade: ".item(style='height:{{height}}px;color:{{color}}')"
    
calendar:
    label: 'Calendar',  router: {}
    jade: -> slice ".row|>#container-calendar|>.scrollspy#top top|#items|.scrollspy#bottom bottom"
    rendered: ->
        $scrollspy = $('.scrollspy')
        $scrollspy.scrollSpy()
        $scrollspy.on 'scrollSpy:enter', -> 
            if 'top' == $(@).attr 'id'
                month_year = moment($('#top').next().children().first().attr('id'),'YYYYMM').subtract(1, 'month').format('YYYYMM')
                console.log 'top', month_year
                $('#items').prepend("<div class=month id=#{month_year}></div>")
                $('html, body').animate({ scrollTop: 5000 }, 0)
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
    styl: -> slice '''#container-calendar|>width 1180px|max-width 1180px ~
        |<.tile|>width 160px|height 160px|float left|padding 8px|border 1px|background-color white|margin 2px ~
        |<h2|>color black|margin-top 1000px|display block ~
        |<.month|>display block|<.break|>display block|height 160px|width 1px'''

day:
    jade: -> slice '.date {{date}}|.day {{day}}|.title Title|.event Event'
    helpers:
        events: -> [{}]
        date: -> moment(@date_str, 'YYYYMMDD').format('D')
        day:  -> moment(@date_str, 'YYYYMMDD').format('ddd')
        title: -> db.Title.find({id:@id})
        event: -> db.Event.find({id:@id})
    styl: -> slice '''.date|>display:inline|font-weight 600|margin-right 10px ~
        |<.day|>display inline|margin-right 10px|<.event|>margin-top 10px|margin-left 5px ~
        |<.title|>display inline|contenteditable true'''

help:
    label: 'Help',   router: {}
    jade: -> slice ".row|>.h2 Debug|<.row#help"
    rendered: -> $help = $ '#help'

footer: 
    jade: -> slice ".footer|>.content|>.row|>center © 2009 - 2014 Startup Edmonton ❘ 301 - 10359 104 Street, Edmonton, Alberta T5J 1B9 ❘ hello@startupedmonton.com"
    styl: -> slice ".footer|>background-color #d9d9d9|padding-top 50px|padding-bottom 20px"


            
