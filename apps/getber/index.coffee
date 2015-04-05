#

fym = 'YYYYMM'
date_box_size = 120
calendar_size = date_box_size * 7 + 14

module.exports.index =

    logo:
        jade: '#logo': 'Getber'
        styl: '#logo': width: 110, float: 'left', padding: 15, fontWeight: '200', fontSize: 15, color: 'white', textAlign: 'right'

    layout: 
        jade: '+navbar': '', '#wrapper': '+sidebar': '', '+yield': ''
        styl: body: backgroundColor: '#ddd'
        navbar: sidebar: true, login: true, menu: 'home map calendar vehicle request log help'

    home:
        label: 'Home', sidebar: 'sidebar_home',  router: path: '/'  
        jade: '#contentWrapper': 
                'h2#title':      'Sign up with UBER'
                '.col-md-6#e1':
                    'p#name':    'Isaac Han'
                    'p#address': '2353 Hagen Link NW, Edmonton, AB T6R 0B2'
                    br: ''
                    'with uber': '+button': ''
                '.col-md-6#e2':  'a(class="btn-info", href="<%= @oauth %>") Connect with Uber': ''
                '.col-md-6#e3':  'S {{hello}}'
                '#items': '.col-md-11#pack': 'each items': '+item': ''
        eco: -> oauth: -> x.oauth Settings.private.uber.oauth
        methods:
            hello: (name) -> 'Hello ' + name + '!'
        helpers: 
            items: -> db.Items.find {}, sort: created_time: -1
            uber:  -> class:'btn-success', id:'uber-botton', label: 'Connect with Uber'
            hello: -> Session.get 'hello2'
        events:
            'click #uber-botton': (event) -> console.log 'uber'
        styl: 
            '#items .item':backgroundColor:'white', width:240, height:240, float:'left', margin:6
            '#title':   width:500 
            '#name':    width:200 
            '#address': width:400
        onCreated: ->
            Meteor.call 'hello', 'world', (e, result) -> Session.set 'hello2', result 
        onRendered: -> 
            x.timeout 40, -> $('#pack').masonry itemSelector: '.item', columnWidth: 126
            ('title name address'.split ' ').map (edit) -> $('#' + edit).editable()
 
    sidebar_home: x.sidebar ['home', 'calendar', 'help']
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
            p:'access_token is {{token}} {{output}}'
        helpers:
            token: -> x.hash().access_token
            output: -> JSON.stringify Session.get('uber_profile'), null, 4
        onCreated: -> x.call 'uber_profile', token:x.hash().access_token

    vehicle:
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
        styl: '#map-canvas': height: '100%', padding: 0, margin: 0
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
        styl:
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
        styl:
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
            'Address |address |Your home Zip code |envelope']
        events: x.popover 'name phone address' .split ' '
        atRendered:
            '.ui-datepicker': borderRadius: 0
            '.ui-datepicker-header': removeClass: 'ui-corner-all ui-widget-header'#, backgroundColor: '#eee', borderRadius: 0
            '#ui-datepicker-div':    removeClass: 'ui-corner-all ui-widget'
            #'.ui-datepicker-prev': {}
            #'.ui-datepicker-next': {}
            #'.ui-datepicker-title': fontWeight: ''
            #'.ui-datepicker-month': 
            #'.ui-datepicker-year':
            #'.ui-datepicker-calendar':
            #'.ui-datepicker-current-day':
            #'.ui-datepicker-today':
        onRendered: -> 
            $('#datepicker').css( "opacity", '50%' ).datepicker()
            datepicker = document.querySelector '#datepicker'
            datepicker.addEventListener 'focus', ->
                console.log 'focus'
                datepicker.removeEventListener 'focus'
                x.timeout 100, -> $('.ui-datepicker-header').removeClass 'ui-corner-all ui-widget-header'
            x.timeout 100, -> $('#mobile-number').intlTelInput 
                preferredCountries: ["ca", "us"]
                utilsScript: "http://jackocnr.com/lib/intl-tel-input/lib/libphonenumber/build/utils.js"
            #$('#ui-datepicker-div').removeClass('ui-corner-all')
            #$('.ui-datepicker-header').removeClass('ui-corner-all')
    popover_name:    jade: ul:'li Write your name.':'', 'li No longer then 12 letters.':''
    popover_phone:   jade: ul: li:'Write your phone number.'
    popover_address: jade: ul: li:'Write your zipcode.'

    help: label: 'Help', router: {}, jade: '#contentWrapper':h1:'Help'

