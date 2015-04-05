#!/usr/bin/env coffee

global.x = {$:{}} if !x?         # for cake
module.exports.x = x if !Meteor? # for cake

x.extend = (object, properties) -> object[key] = val for key, val of properties; object
x.capitalize = (str) -> str[0].toUpperCase() + str[1..]
x.isLowerCase = (char, index) -> 'a' <= char[index] <= 'z'
x.isString = (str) -> str? and 'string' == typeof str and str.length > 0
x.isVisible = (v) -> if 'function' == typeof v then v() else if false is v then false else true
x.isPortableKey = (str) -> /^[a-z]+$/i.test str # . or #
x.isDigit = (str) -> /^[0-9]+$/.test str
x.value = (value) ->
    if      'number'   == typeof value then value.toString() + 'px'
    else if 'string'   == typeof value then value # (value = value.replace v,k for k,v of repcode()).pop()
    else if 'function' == typeof value then value() else value
x.timeout = (time, func) -> Meteor.setTimeout func, time
x.func = (func) -> 
    if 'function' == typeof func then func() 
    else if 'undefined' == func then {} else func
x.funcConcat = (func1, func2) -> -> func1() ; func2()
x.keys = (obj) -> Object.keys obj

x.isValue = (v) -> if 'string' == typeof v || 'number' == typeof v then v else false
x.interpolate = (str, o) -> str.replace /{([^{}]*)}/g, (a, b) -> x.isValue(o[b]) or a
x.fillObj = (o, data) -> 
    x.keys(o).map (k) -> o[k] = x.interpolate o[k], data
    o
x.call = (key, o) -> Meteor.call key, o, (e, r) -> 
    if e then Session.set(key + '_error', e) else Session.set key, r
x.o = (obj, depth=1) -> 
    ((Object.keys obj).map (key) ->
        value = obj[key]
        key = x.toDash(key) if x.isPortableKey(key)
        (Array(depth).join '    ') + 
        if  'object' == typeof value then [key, x.o(value, depth + 1)].join '\n'
        else if '' is value          then key
        else if '' is key or x.isDigit(key) then x.value value
        else key + ' ' + x.value value
    ).join '\n'

x.toDash = (str) -> if str? then str.replace /([A-Z])/g, ($1) -> '-' + $1.toLowerCase() else null

x.query = -> Iron.Location.get().queryObject
x.hash  = -> 
    ((Iron.Location.get().hash[1..].split '&').map (a) -> a.split '=').reduce ((p, c) ->  p[c[0]] = c[1]; p), {}

x.repeat = (str, times) -> Array(times + 1).join str
x.queryString = (obj, delimeter='&') ->
    (encodeURIComponent(i) + "=" + encodeURIComponent(obj[i]) for i of obj).join delimeter
x.decode = (str, code, repeat) -> 
    decode = encodeURIComponent code
    str.replace( new RegExp("(?:#{decode}){#{repeat}}(?!#{decode})", 'g'), x.repeat(code, repeat))
x.saveMustache = (str) -> x.decode( x.decode( str, '{', 2 ), '}', 2 )
x.trim = (str) -> if str? then str.trim() else null
x.capitalize = (string) -> string.charAt(0).toUpperCase() + string.slice(1)
x.dasherize = (str) -> str.trim().replace(/([A-Z])/g, "-$1").replace(/[-_\s]+/g, "-").toLowerCase()
x.prettyJSON = (obj) -> JSON.stringify obj, null, 4
x.getValue = (id) ->
    element = document.getElementById(id)
    if element then element.value else null
x.trimmedValue = (id) ->
        element = document.getElementById(id)
        if element then element.value.replace(/^\s*|\s*$/g, "") else null

validateRe =
    email: /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i

x.validate = (key, value) -> validateRe[key].test value

x.reKey = (obj, oldName, newName) ->
        if obj.hasOwnProperty(oldName)
            obj[newName] = obj[oldName]
            delete obj[oldName]
        @

x.slice = (str, tab=1, indent='    ') -> (((str.replace /~\s+/g, '').split '|').map (s) ->
    s = if 0 == s.search /^(<+)/ then s.replace /^(<+)/, Array(tab = Math.max tab - RegExp.$1.length, 1).join indent 
    else if 0 == s.search /^>/ then s.replace /^>/, Array(++tab).join indent 
    else s.replace /^/, Array(tab).join indent).join '\n'

x.insertTemplate = (page, id, data={}) ->
    $('#' + id).empty()
    Blaze.renderWithData(
        Template[page], 
        if Object.keys(data).length then data else Template[page].helpers 
        document.getElementById id  )

x.currentRoute = -> Router.current().route.getName()
x.render = (page) -> Template[page].renderFunction().value

x.renameKeys = (obj, keyObject) ->
    _.each _.keys keyObject, (key) -> x.reKey obj, key, keyObject[key]

x.repeat = (pattern, count) ->
    return '' if count < 1
    result = ''
    while count > 0
        result += pattern if count & 1
        count >>= 1
        pattern += pattern
    result

x.deepExtend = (target, source) ->
    for prop of source
        if prop of target
            x.deepExtend target[prop], source[prop]
        else
            target[prop] = source[prop]
    target


x.flatten = (obj, chained_keys) ->
    toReturn = {}       
    for i in obj
        if typeof obj[i] == 'object'
            flatObject = x.flatten obj[i]
            for j in flatObject
                if chained_keys
                    toReturn[i+'_'+j] = flatObject[j]
                else
                    toReturn[j] = flatObject[j]
        else
            toReturn[i] = obj[i]
    toReturn

x.position = (obj) ->
    Meteor.setTimeout ->
        $('#'+obj.parentId+' .'+obj.class).css top:obj.top, left:obj.left, position:'absolute'
    , 200

x.contentEditable = (id, func) ->
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
            else
                $cloned.html $(@).html()
            console.log $cloned.css opacity: 1
            console.log $(@).css overflow:'visible', opacity: 0
            Meteor.setTimeout =>
                $(@).css overflow:'hidden', opacity: 1
                $cloned.css opacity: 0
            ,
                200

x.scrollSpy = (obj) ->
    $$ = $ '.scrollspy'
    $$.scrollSpy()
    ['enter', 'exit'].forEach (a) ->
        $$.on 'scrollSpy:' + a, -> obj[a][$(@).attr 'id']() if obj[a]?

x.calendar = (fym, id_ym) ->
    action = if moment().format(fym) > id_ym then 'prepend' else 'append'
    $('#items')[action](DIV class:'month', id:id_ym)
    moment_ym = moment(id_ym, fym)
    top = $(window).scrollTop()

    ($id = $ '#' + id_ym).append H2 id:id_ym, moment_ym.format 'MMMM YYYY'    
    [1..parseInt moment_ym.startOf('month').format 'd'].forEach (i) ->
        $id.append DIV class:'everyday empty', style:'visibility:hidden'
    [1..parseInt moment_ym  .endOf('month').format 'D'].forEach (i) ->        
        $id.append DIV class:'everyday', id:id = id_ym + ('0' + i)[-2..]
        x.insertTemplate 'day', id, id:id
        x.contentEditable id, (_id) ->
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
        x.timeout 10, -> $(window).scrollTop top + $id.outerHeight()
        $('#top'   ).data id:id_ym
    else
        $('#bottom').data id:id_ym

x.oauth = (obj) -> obj.url + "?" + x.queryString obj.query

x.list = (what) -> # add id
    ((what = if 'string' == typeof what then what.split ' ' 
    else if Array.isArray(what) then what else [])
        .map (a) -> ".#{a} {{#{a}}}").join '\n'


x.sidebar = (list, id='sidebar_menu') ->
    list: list
    jade: -> x.o 'each items': '+menu_list': ''
    helpers: 
        items: -> list.map (a) -> { page:a, id:id } # ̵̵̵correct - id must unique.

x.assignPopover = (o,v) -> 
    o['focus input#'+v] = -> 
        $('input#'+v)
            .attr('data-content', x.render 'popover_'+v)
            .popover 'show' 
    o

x.popover = (list) -> list.reduce ((o, v) -> x.assignPopover o, v), {}

x.log = ->
    (arguments != null) and ([].slice.call(arguments)).concat(['\n']).map (str) ->
        if Meteor.isServer then fs.appendFileSync Config.log_file, str + ' ' # fs? server?
        else console.log str

