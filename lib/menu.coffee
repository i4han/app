

getMenu = (Pages) ->
    _ = require 'underscore'
    _.templateSettings = interpolate: /\[(.+?)\]/g
    menu  = Pages.layout.navbar.menu
    ((if 'string' == typeof menu then menu.split ' ' 
    else if Array.isArray(menu) then menu else []).map (a) -> 
        ( _.template """            li: a(href="{{pathFor '[path]'}}" id='[id]') [label]""" )
            path:a, label:Pages[a].label, id:'navbar-menu'
    ).join '\n'

module.exports.menu =

    menu_list:
        jade: li:'a(href="{{path}}" id="{{id}}")': '{{label}}'
        helpers: 
            path:  -> Router.path @page 
            label: -> Pages[@page].label
            
    navbar:                                    # seperate menu_list and navbar
        jade: ->
            menu = getMenu(@Pages)
            """
            .navbar.navbar-default.navbar-#{@Theme.navbar.style}
                +logo
                .navbar-left 
                    ul.nav.navbar-nav
                        li: a#menu-toggle: i.fa.fa-bars
            #{menu}
                .navbar-right
                    +login
            """
#        styl: -> @_.slice ".navbar|>background-color rgba(20, 23, 240, 0.7)|<.navbar-fixed-top|>border 0px"
        styl: 
            '.navbar':backgroundColor:'rgba(20, 23, 240, 0.7)'
            '.navbar-fixed-top':border:0
        events:
            'click #menu-toggle': (event) -> $("#wrapper").toggleClass "toggled" # event.preventDefault()                
            'click #navbar-menu': (event) ->
                menu_selected = event.target.innerText.toLowerCase()
                $('#listen-to-menu-change').trigger 'custom', [menu_selected]

        styl$: ->
            T = @Theme.navbar 
            """
            #menu-toggle
                width 50px
            #login-buttons
                height 50px
                width #{T.login.width}
            li#login-dropdown-list
                width #{T.login.width}
                height #{T.height}
                display table-cell
                text-align center
                vertical-align middle
            .navbar-default .navbar-nav > li > a
                color #{T.text.color}
            .navbar-left > ul > li > a
                width #{T.text.width}
                text-align center
            .navbar-right > li:hover
            .navbar-left > ul > li:hover
            .navbar-nav > li > a:hover
                text-decoration none
                color #{T.hover.color}
                background-color #{T.hover.background_color}
            .dropdown-toggle > i.fa-chevron-down
                padding-left 4px
            #navbar-menu:focus
                color black
                background-color #{T.focus.background_color}
            #login-dropdown:hover
                cursor pointer
            #login-dropdown-list > a
                width  #{T.login.width}
                height #{T.height}
                color  #{T.text.color}
                text-decoration none
                cursor pointer
                padding ( ( #{T.height} - #{T.text.height} ) / 2 )
            #login-dropdown-list > a:hover
                background-color #{T.hover.background_color}
            """
    sidebar:
        styl$: -> sidebar_width = '160px'; """
            #wrapper 
                padding-top: 50px;
                padding-left: 0px;
                -webkit-transition: all 0.5s ease;
                -moz-transition: all 0.5s ease;
                -o-transition: all 0.5s ease;
                transition: all 0.5s ease; /* (-webkit-|-moz-|-o-|)transition */
            #wrapper.toggled 
                padding-left: #{sidebar_width};
            #sidebar-wrapper
                z-index: 1000;
                position: fixed;
                left: 0; /* #{sidebar_width}; */
                width: 100;
                height: 100%;
                padding-top: 50px
                margin-left: 0; /* -#{sidebar_width}; */
                overflow-y: auto;
                background: #aaa;
                -webkit-transition: all 0.5s ease;
                -moz-transition: all 0.5s ease;
                -o-transition: all 0.5s ease;
                transition: all 0.5s ease;
            #wrapper.toggled #sidebar-wrapper
                margin-left: -#{sidebar_width}; /* width: #{sidebar_width}; */
            #content-wrapper
                width: 100%;
                padding: 15px;
            #wrapper.toggled #content-wrapper
                position: absolute;
                margin-right: -#{sidebar_width};
            .sidebar-nav
                position absolute
                top 40px
                width #{sidebar_width}
                margin 0
                padding 0
                list-style none
            .sidebar-nav li
                text-indent 20px
                line-height 40px
            .sidebar-nav li a 
                display block
                text-decoration none
                color #{@Theme.sidebar.a.color}
            .sidebar-nav li a:hover
                text-decoration: none
                color #000
                background-color #e8e8e8
            .sidebar-nav li a:active,
            .sidebar-nav li a:focus
                text-decoration none
                color #000
                background-color #ddd
            .sidebar-nav > .sidebar-brand
                height 65px
                font-size 18px
                line-height 60px
            .sidebar-nav > .sidebar-brand a
                color #999
            .sidebar-nav > .sidebar-brand a:hover
                color #fff
                background none
            @media(min-width:768px)
                #wrapper
                    padding-left #{sidebar_width}
                    height 100%
                #wrapper.toggled 
                    padding-left 0
                #sidebar-wrapper
                    width #{sidebar_width};
                #wrapper.toggled #sidebar-wrapper
                    /* width: 0; */
                #wrapper.toggled #content-wrapper
                    position relative
                    margin-right 0
            """
        jade: """
            form#listen-to-menu-change
            #sidebar-wrapper
                #sidebar-top
                ul.sidebar-nav#sidebar_menu_insert
            """
        rendered: ->
            $('#listen-to-menu-change').trigger('custom', [x.currentRoute()])
        events:
            'custom #listen-to-menu-change': (event, instance, navbar_menu) ->
                sidebar = Pages[navbar_menu].sidebar
                if sidebar? and 'string' == typeof sidebar and sidebar.length > 0 # x.isString sidebar
                    x.insertTemplate sidebar, 'sidebar_menu_insert'
                    $("#wrapper").removeClass "toggled"
                else
                    $('#'+sidebar).empty()
                    $("#wrapper").addClass "toggled"
        
    __style:
        __styl: """
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

  



