

fym = 'YYYYMM'
date_box_size = 120
calendar_size = date_box_size * 7 + 14
fullsize   = -> width: '100%', height: '100%'
fullscreen = (zIndex) -> position: 'fixed', top: 0, left: 0, zIndex: zIndex
bigButton  = (color)  -> backgroundColor: color, borderWidth: 2, borderColor: color, height: 50, width: 210, fontSize: 20
module.exports.index =

logo:
    jade: li: '#logo': 'Getber'
    absurd: '#logo': height: 50, width: 110, float: 'left', padding: 15, fontWeight: '200', fontSize: 15, color: 'white', textAlign: 'center'

layout: 
    jade: '+navbar': '', '#wrapper': '+sidebar': '', '+yield': ''
    absurd: body: backgroundColor: '#ddd'
    navbar: sidebar: true, login: true, menu: 'home map calendar request log help'

layout_naked:
    jade: '+yield'
main:
    label: 'main', router: path: '/', layoutTemplate: 'layout_naked'
    jade: 
        '#bg': ''
        '#screen-bg': ''
        '#video': ''
        '.logo#logo-left':  'get'
        '.logo#logo-right': 'ber'
        '#hero':
            '#hero-copy': 'Safeguard your family rides'
            '.copy#e1':   'For parents'
            '.copy#e2':
                '+button(label="Connect with UBER")': ''
                '+br(height="2")': ''
            '.copy#e3':   'For 18 years or yonger'
            '.copy#e4':
                '+button(label="Sign up for Teens")': ''
    events:
        'click #connect-with-uber': -> Router.go '/forward/uber_oauth'
    absurd: ->
        '#bg':        [fullscreen(-100), fullsize(), backgroundColor: '#333']
        '#screen-bg': [fullscreen(-10),  fullsize(), @Settings.screen_bg]
        '#bg-video':  [fullscreen(-100), height: '100.0%', marginLeft: 0, display: 'block']
        '#video':      height: 50
        '.logo':       marginTop:  60, fontSize: 40, color: 'white', padding: 2, display: 'inline'
        '#logo-left':  marginLeft: 80, backgroundColor: 'blue'
        '#logo-right': marginLeft: 0,  backgroundColor: 'green'
        '#connect-with-uber': bigButton('blue')
        '#sign-up-for-teens': bigButton('green')
        '.copy': 
            marginLeft: 80, textAlign: 'left', 
            fontSize:   32, color: 'white', textShadow: '1px 1px 5px #000'
        '#hero': width: 700, paddingBottom: 20, backgroundColor: 'rgba(255,255,255,0.15)'
        '#hero-copy': 
            marginTop: 40, marginLeft: 80, textAlign: 'left', 
            fontSize: 48,  color: 'white', textShadow: '1px 1px 3px #000'
    eco: -> hero: -> @Settings.lander.hero
    on$Ready: ->
        $(@).resize ->
            if  movie and (window_width = $(@).width()) / (window_height = $(@).height()) > 1.78 
                movie.remove('height').set 'width', '100%'               
                $video.css('margin-left','').css 'margin-top',  px (window_height - $video.height())/2
            else if movie
                movie.remove('width').set 'height', '100%'
                $video.css('margin-top','').css 'margin-left', px (window_width  - $video.width() )/2
    onStartup: ->
        @movie = x.style '#bg-video'
    onRendered: ->
        $('body').css 'background-image', 'url("/screen-bg.png"))'
        video = """
            <video id="bg-video" preload="auto" autoplay="true" loop="loop" muted="muted" volume="0" src="/uber.mp4">
                <source src="/uber.mp4" type="video/mp4">
            </video>"""
        @$video = $(video).insertAfter('#video')
        x.timeout 100, -> $(@).resize()
    onDestroyed: ->
        $('body').css 'background-image', ''

home: 
    label: 'Home', sidebar: 'sidebar_home',  router: path: 'home'  
    jade: '#contentWrapper': 
            'h2#title': 'Sign up with UBER'
            '+button(label="Connect with UBER")': ''                    
            '.col-md-6#e3':  'See you soon{{hello}}'
            '#items': '.col-md-11#pack': 'each items': '+item': ''
    eco: -> oauth: -> x.oauth 'uber'
    methods: 
        hello: (name) -> 'Hello ' + name + '!'
        uber_oauth: -> x.oauth 'uber'
    helpers: 
        items: -> db.Items.find {}, sort: created_time: -1
        hello: -> Session.get 'hello'
    events:
        'click #connect-with-uber': -> Router.go '/forward/uber_oauth'
    absurd: 
        '#items .item':backgroundColor:'white', width:240, height:240, float:'left', margin:6
        '#title':   width:500 
        '#name':    width:200 
        '#address': width:400
    onCreated: ->
        #call.hello db:'User'
        Meteor.call 'hello', 'world', (e, result) -> Session.set 'hello', result
        Meteor.call 'uber_oauth', (e, result) -> Session.set 'uber_oauth', result
    onRendered: -> 
        x.timeout 40, -> $('#pack').masonry itemSelector: '.item', columnWidth: 126
        ('title name address'.split ' ').map (edit) -> $('#' + edit).editable()

sidebar_home: x.sidebar ['home', 'calendar', 'help']
world:
    label: 'Hello'
    jade: h1: '{{a}} world'
history:
    label: 'Ride History', router: path: 'history'
    jade: ' '
location:
    lable: 'Locations',    router: path: 'location'

profile:
    lable: 'Profile', sidebar: 'sidebar_profile', router: path: 'profile'
    jade: '#contentWrapper':
                'with user': 
                    '| {{name}}':''
                    '| {{phone}}':''
    helpers:
        user: -> name: 'Isaac Han', phone: 'xxx-xxxx'
        access_token: -> 1

item: jade: ".item(style='height:{{height}}px;color:{{color}}')" 
submit:
    label: 'Submit', router: path: 'submit'
    jade: 
        h2:'Connected'
        '+button(label="Add rider")':''
        p:'access_token is {{token}} {{output}}'
    helpers:
        token: -> x.hash().access_token
        output: -> JSON.stringify Session.get('uber_profile'), null, 4
    onCreated: -> x.call 'uber_profile', token:x.hash().access_token
    absurd: 
        '#add-rider': backgroundColor: 'green', borderWidth: 2, borderColor: 'green', height: 30, width: 150, fontSize: 12
    events:
        'click #add-rider': -> console.log 'add rider'

__vehicle:
    label: 'Vehicle', sidebar: 'sidebar_vehicle', router: path: 'vehicle'
    jade: '#contentWrapper': 
            h1: 'You vehicle information', br: ''
            '.col-sm-7': 'each items': '+form': '', br:'' 
    helpers: items: -> [
            { label: 'Maker', id: 'maker', title: 'Car manufacturer',      icon: 'mobile' },
            { label: 'Model', id: 'model', title: 'Year of the model',     icon: 'mobile' },
            { label: 'Color', id: 'color', title: 'Color of your vehicle', icon: 'mobile' }]
    events: x.popover 'maker model color' .split ' '
popover_maker: jade: ul:li: 'manufacturer in 20 characters'
popover_model: jade: ul:li: 'For digit'
popover_color: jade: ul:li: 'White or black only'
sidebar_vehicle: x.sidebar 'home map calendar request vehicle log help'.split ' '             

map: 
    label: 'Map', sidebar: 'sidebar_map', router: path: 'map'
    jade: '#map-canvas'
    absurd: '#map-canvas': height: '100%', padding: 0, margin: 0
    onRendered: ->
        google.maps.event.addDomListener window, 'load', Pages.map.map_init
        x.timeout 10, Pages.map.map_init
    map_init: -> 
        new google.maps.Map document.getElementById('map-canvas'), 
            disableDefaultUI: true, zoom: 11, center: lat: 53.52, lng: -113.5
sidebar_map: x.sidebar 'home map calendar request vehicle log help'.split ' '             
            
calendar:
    label: 'Calendar',  router: {}
    jade: '#contentWrapper':
            '#containerCalendar': '.scrollspy#top': '&nbsp;', '#items': '', '.scrollspy#bottom': '&nbsp;'
    onRendered: -> 
        x.calendar fym, this_month = moment().format fym
        $('#top').data id:this_month
        x.scrollSpy enter:
            top:    -> x.calendar moment($('#top'   ).data('id'), fym).subtract(1, 'month').format fym
            bottom: -> x.calendar moment($('#bottom').data('id'), fym).add(     1, 'month').format fym
    styl:
        '#containerCalendar': width: calendar_size, maxWidth: calendar_size
        h2: color:'black', display:'block' 
        '.everyday': position: 'relative', width:date_box_size, height:date_box_size, float:'left', padding:8, backgroundColor:'white', margin:2           
        '.month':    display:'block', height: calendar_size
        '.spacer':   lineHeight: 10
log:
    label: 'Log', router: path: 'log'
    jade:  '#log-canvas'
    onRendered: -> $('#log-canvas').html '<object id="full-screen" data="http://localhost:8778/"/>'
    absurd:
        '#log-canvas':  height: '100%', width: '100%'
        '#full-screen': height: '100%', width: '100%'
policy:
    label: 'Policy', router: path: 'policy'
    jade: h2:'Privacy Policy'
uber:
    label: 'uber',   router: path: 'uber'
    jade: h2:'Uber'
redirect:
    label: 'redirect', router: path: 'redirect'
    jade: h2:'redirect'
day:
    collection: 'calendar'
    jade: x.list 'init title date day event'
    helpers:
        date:  -> moment(@id, 'YYYYMMDD').format 'D'
        day:   -> moment(@id, 'YYYYMMDD').format 'ddd'
        title: -> db.Calendar.findOne({id:@id})?['title'] or 'Title'
        event: -> '' #gCal[@id] or ''
        init:  ->
            x.position parentId:@id, class:'title', top:14,
            x.position parentId:@id, class:'event', top:45,
            x.position parentId:@id, class:'date',  top: 5, left:(date_box_size - 35)
            x.position parentId:@id, class:'day',   top:28, left:(date_box_size - 37)
            ''
    absurd:
        '.init':  display:'none'
        '.title': display:'inline', fontWeight:'100'               
        '.date':  display:'inline', fontWeight:'600', fontSize:'14pt', width:24, textAlign:'right'
        '.day':   display:'table',  fontWeight:'100', float:'right',   width:24, textAlign:'right', color:'#444',  fontSize: '8pt'
        '.event': resize:'none',    fontWeight:'100'
        '.row#day01': marginBottom:0
gmap:
    jade: 
        'input(id="pac-input", class="controls", type="text", placeholder="Enter a location")': ''
        '#map-canvas': ''
    onRendered: -> 
        google.maps.event.addDomListener window, 'load'
        x.timeout 10, -> x.gmapInit 
            disableDefaultUI: true, mapTypeId: "roadmap", zoom: 11, center: lat: 53.52, lng: -113.5

request:
    label: 'Request', router: path: 'request'
    jade: '#contentWrapper': 
            h1: 'Request', br: ''
            '.col-sm-9#e11': 'each items': '+form': '', br:''
            '.col-sm-9#e12': 'input(type="tel",id="mobile-number",class="form-control")':'', br:''
            '.col-sm-9#e13': '+gmap': ''
    styl: '#e13': height: 300
    helpers: items: -> [
            { label: 'Phone',   id: 'phone',     title: 'Phone Number',    icon: 'mobile'   }
            { label: 'Date',    id: 'datepicker',title: 'Pick your date',  icon: 'calendar' }
            { label: 'Name',    id: 'name',      title: 'Your name',  icon: 'user'     }
        ]
    __helpers: items: -> [ 'label, id, title, icon'
        'Name    |name    |Your name          |user'
        'Phone   |phone   |Phone Number       |mobile'
        'Address |address |Your home Zip code |envelope' ]
    events: x.popover 'name phone address' .split ' '
    onRendered: -> 
        $('#datepicker').css( "opacity", '50%' ).datepicker()
        datepicker = document.querySelector '#datepicker'
        datepicker.addEventListener 'focus', ->
            console.log 'focus'
            datepicker.removeEventListener 'focus'
            x.timeout 100, -> $('.ui-datepicker-header').removeClass 'ui-corner-all ui-widget-header'
        x.timeout 100, -> $('#mobile-number').intlTelInput 
            preferredCountries: ["ca", "us"]
            utilsScript: "/utils.js"
        $('#ui-datepicker-div').removeClass('ui-corner-all')
        #$('.ui-datepicker-header').removeClass('ui-corner-all')
popover_name:    jade: ul:'li Write your name.':'', 'li No longer then 12 letters.':''
popover_phone:   jade: ul: li:'Write your phone number.'
popover_address: jade: ul: li:'Write your zipcode.'

help: 
    label: 'Help', router: {}, 
    jade: '#contentWrapper':
            h1:'style'
            pre:'{{output}}'
    helpers: output: ->
        sheets = document.styleSheets
        ([0..sheets.length].map (i) ->
            sheets[i]? and (rules = sheets[i].cssRules)? and ([0..rules.length].map (j) ->
                rules[j]? and "#{i}:#{j}\n" + rules[j].cssText).join '\n').join '\n'          

