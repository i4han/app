

getMenu = (Module) ->
    _ = require 'underscore'
    _.templateSettings = interpolate: /\[(.+?)\]/g
    menu  = Module.layout.navbar.menu
    ((if 'string' == typeof menu then menu.split ' ' 
    else if Array.isArray(menu) then menu else []).map (a) -> 
        ( _.template """            li: a(href="{{pathFor '[path]'}}" id='[id]') [label]""" )
            path:a, label:Module[a].label, id:'navbar-menu'
    ).join '\n'

module.exports.menu =

    menu_list:
        jade: li:'a(href="{{path}}" id="{{id}}")': '{{label}}'
        helpers: 
            path:  -> Router.path @name 
            label: -> Module[@name].label
            
    navbar:                                    # seperate menu_list and navbar
        jade: ->
            menu = getMenu(@Module)
            """
            .navbar.navbar-default.navbar-#{@Theme.navbar.style}
                .navbar-left 
                    ul.nav.navbar-nav
                        li: a#menu-toggle: i.fa.fa-bars
                        +logo
            #{menu}
                .navbar-right
                    +login
            """
        styl: ->
            '.navbar': backgroundColor:@Theme.navbar.backgroundColor
            '.navbar-fixed-top': border: 0
        events:
            'click #menu-toggle': (event) -> $("#wrapper").toggleClass "toggled" # event.preventDefault()                
            'click #navbar-menu': (event) ->
                menu_selected = event.target.innerText.toLowerCase()
                $('#listen-to-menu-change').trigger 'custom', [menu_selected]

        styl$: ->
            T = @Theme.navbar 
            '#menu-toggle': width: 50
            '#login-buttons': height: 50, width: T.login.width
            'li#login-dropdown-list': 
                width: T.login.width, height: T.height, display: 'table-cell'
                textAlign: 'center', verticalAlign: 'middle'
            '.navbar-default .navbar-nav > li > a:focus': backgroundColor: T.focus.backgroundColor
            '.navbar-default .navbar-nav > li > a': color: T.text.color
            '.navbar-left > ul > li > a': width: T.text.width, textAlign: 'center'
            '.navbar-right > li:hover, .navbar-left > ul > li:hover, .navbar-nav > li > a:hover':
                textDecoration: 'none', color: T.hover.color, backgroundColor: T.hover.backgroundColor
            '.dropdown-toggle > i.fa-chevron-down': paddingLeft: 4,
            '#navbar-menu:focus': color: 'black', backgroundColor: T.focus.backgroundColor
            '#login-dropdown:hover': cursor: 'pointer'
            '#login-dropdown-list > a': 
                width: T.login.width, height: T.height, color: T.text.color
                textDecoration: 'none', cursor: 'pointer', padding: (T.height - T.text.height) / 2
            '#login-dropdown-list > a:hover': backgroundColor: T.hover.backgroundColor
    sidebar: 
        absurd: -> 
            sidebar_width = 160
            '#wrapper': 
                paddingTop: 50, paddingLeft: 0, Transition: 'all 0.5s ease', 
                '@media(min-width:768px)': paddingLeft: sidebar_width, height: '100%'
                #-webkit-transition: all 0.5s ease;
                #-moz-transition: all 0.5s ease;
                #-o-transition: all 0.5s ease;  
            '#wrapper.toggled': paddingLeft: sidebar_width, '@media(min-width:768px)': paddingLeft: 0
            '#sidebar-wrapper': 
                zIndex: 1000, position: 'fixed', left: 0, width: 100, height: '100%', paddingTop: 50
                marginLeft: 0, overflowY: 'auto', background: 'rgba(0, 160, 0, 0.6)', Transition: 'all 0.5s ease'
                '@media(min-width:768px)': width: sidebar_width
            '#wrapper.toggled #sidebar-wrapper': marginLeft: -sidebar_width
            '#content-wrapper': width: '100%', padding: 15
            '#wrapper.toggled #content-wrapper': 
                position: 'absolute', marginRight: -sidebar_width
                '@media(min-width:768px)': position: 'relative', marginRight: 0
            '.sidebar-nav': position: 'absolute', top: 40, width: sidebar_width, margin: 0, padding: 0, listStyle: 'none'
            '.sidebar-nav li': textIndent: 20, lineHeight: 40
            '.sidebar-nav li a': display: 'block', textDecoration: 'none', color: @Theme.sidebar.a.color
            '.sidebar-nav li a:hover': textDecoration: 'none', color: '#000', backgroundColor: '#e8e8e8'
            '.sidebar-nav li a:active, .sidebar-nav li a:focus': textDecoration: 'none', color: '#000', backgroundColor: '#ddd'
            '.sidebar-nav > .sidebar-brand': height: 65, fontSize: 18, lineHeight: 60
            '.sidebar-nav > .sidebar-brand a': color: '#999'
            '.sidebar-nav > .sidebar-brand a:hover': color: '#fff', background: 'none'
        jade: ['form#listen-to-menu-change', '#sidebar-wrapper': ['#sidebar-top', 'ul.sidebar-nav#sidebar_menu_insert']]
        rendered: -> $('#listen-to-menu-change').trigger('custom', [x.currentRoute()])
        events:
            'custom #listen-to-menu-change': (event, instance, navbar_menu) ->
                sidebar = Module[navbar_menu].sidebar
                if sidebar? and 'string' == typeof sidebar and sidebar.length > 0 # x.isString sidebar
                    x.insertTemplate sidebar, 'sidebar_menu_insert'
                    $("#wrapper").removeClass "toggled"
                else
                    $('#'+sidebar).empty()
                    $("#wrapper").addClass "toggled"

"""
            .navbar-inner
                padding 0              
            .navbar-header
                float left
            .navbar-right
                border 0
                padding 0
                margin 0
            .navbar-brand
                font-size 14px
            .navbar-header > a.navbar-brand:hover
                color black
                background-color #eee
            .navbar-right > li > a.dropdown-toggle
                color #555
                padding-right 12px
            .navbar-header > a.navbar-brand:focus
            .navbar-right > li > a.dropdown-toggle:focus
            .navbar-nav > li > a:focus
                color black
                background-color #ddd
            .navbar-collapse
                float left
                width 500px
            #btn-toggle-collapsed
                height 34px
                width 38px
                padding-left 1px
                padding-right 5px
                padding-top 5px
                padding-bottom 2px
                margin 8px
            .fa-bars:before
                font-size 18px
                content "\f0c9"
"""

  



