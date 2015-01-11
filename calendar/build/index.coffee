#!/usr/bin/env coffee

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
    $('#'+id)
        .on 'focus', '[contenteditable]', ->
            console.log 'focus'
            $this = $(this)
            $this.data 'before', $this.html()
            return $this
        .on 'blur keyup paste input', '[contenteditable]', ->
            id = $(this).parent().attr('id')
            content = $(this).html()
            class_ = $(this).attr('class')
            $this = $(this)
            if $this.data('before') isnt $this.html()
                $this.data 'before', $this.html()
                console.log 'Editable', $this.parent(), class_, id, content 
                $this.parent().trigger('change', [class_, id, content] )
            return $this

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
module.exports.index =

    layout: 
        jade: -> slice "+navbar|#wrapper|>#content-wrapper|>.container-fluid|>+yield|<<<+footer"
        styl: -> slice "body|>background-color #ccc"
        navbar: sidebar: true, login: true, menu: 'home calendar help'.split ' '

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
            console.log 'rendered'
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


            
