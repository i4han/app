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
