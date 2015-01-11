eventListener = ->
    $('.tile').on 'change', (obj, claxx, id, content) ->
        console.log 'Listener', claxx, id, content
        if 'title' == claxx
            console.log 'title', db.Title.find({id:id})
            if db.Title.find({id:id}) then db.Title.update(id:id, $set:{content: content})
            else db.Title.insert(id:id, content:content)
        else if 'event' == claxx
            console.log 'event', db.Event.find({id:id})
            if db.Event.find({id:id}) then db.Event.update({id:id, $set:{content: content}})
            else db.Event.insert({id:id, content:content})

#        Pages['day'].Event(claxx, id, content)

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
            claxx = $(this).attr('class')
            $this = $(this)
            if $this.data('before') isnt $this.html()
                $this.data 'before', $this.html()
                console.log 'Editable', $this.parent(), claxx, id, content 
                $this.parent().trigger('change', [claxx, id, content] )
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

# correct - id must unique.
sidebar = (list, id='sidebar_menu') ->
    jade: -> @_.slice "each items|>+menu_list"
    helpers: 
    	items: -> list.map (a) -> { page:a, id:id } 

assignPopover = (o,v) -> 
    o['focus input#'+v] = -> 
        $('input#'+v)
            .attr('data-content', __.render 'popover_'+v)
            .popover 'show' 
    o

popover = (list) -> list.reduce ((o, v) -> assignPopover o, v), {}
