module.exports.navbar =

    navbar:
        jade: (Config) ->
            _ = require 'underscore'
            _.templateSettings = interpolate: /\[(.+?)\]/g
            menu = ''
            Config.$.navbar.list.forEach (a) -> 
                menu += ( _.template """            li: a(href="{{pathFor '[path]'}}" id="[id]") [label]\n""" )
                    path:a.path, label:a.label, id: 'navbar-menu'                
            """
            .navbar.navbar-default.navbar-#{Config.$.navbar.style}: .container
                .navbar-left 
                    ul.nav.navbar-nav
                        li: a#menu-toggle: i.fa.fa-bars
            #{menu}
                .navbar-right
                    +login
            """
        events:
            'click #menu-toggle': (event) ->
                event.preventDefault()
                $("#wrapper").toggleClass "toggled"
            'click #navbar-menu': (event) ->
                Session.set 'sidebar.navbar-menu', event.target.innerText.toLowerCase()
                $('#listen-to-menu-change').trigger('reset')
                
                $('ul.sidebar-nav').html('<li><a>Ready</a></li><li><a>Set</a></li><li><a>Go</a></li>') if event.target.innerText == 'Home'
                $('ul.sidebar-nav').html('<li><a>Red</a></li><li><a>Green</a></li><li><a>Blue</a></li>') if event.target.innerText == 'Connect'
                $('ul.sidebar-nav').html('<li><a>Apple</a></li><li><a>Kiwi</a></li><li><a>Mango</a></li><li><a>Orange</a></li>') if event.target.innerText == 'Profile'
                $('ul.sidebar-nav').html('<li><a>Edmonton</a></li><li><a>Vancouber</a></li><li><a>Toronto</a></li>') if event.target.innerText == 'Help'


        styl$: (Config) -> """
            #menu-toggle
                width 50px
            #login-buttons
                height 50px
                width #{Config.$.navbar.login.width}
            li#login-dropdown-list
                width #{Config.$.navbar.login.width}
                height #{Config.$.navbar.height}
                display table-cell
                text-align center
                vertical-align middle
            .navbar-default .navbar-nav > li > a
                color #{Config.$.navbar.text.color}
            .navbar-left > ul > li > a
                width #{Config.$.navbar.text.width}
                text-align center
            .navbar-right > li:hover
            .navbar-left > ul > li:hover
            .navbar-nav > li > a:hover
                text-decoration none
                color #{Config.$.navbar.hover.color}
                background-color #{Config.$.navbar.hover.background_color}
            .dropdown-toggle > i.fa-chevron-down
                padding-left 4px
            //.navbar-nav > li > a:focus  // it dosen't affect
            //    color black
            //    background-color white
            #login-dropdown-list > a
                width #{Config.$.navbar.login.width}
                height #{Config.$.navbar.height}
                color #{Config.$.navbar.text.color}
                text-decoration none
                cursor pointer
                padding ( ( #{Config.$.navbar.height} - #{Config.$.navbar.text.height} ) / 2 )
            #login-dropdown-list > a:hover
                background-color #{Config.$.navbar.hover.background_color}
            """
    sidebar:
        css: (Config) -> sidebar_width = '180px'; """
            #wrapper {
                padding-top: 50px;
                padding-left: 0px;
                -webkit-transition: all 0.5s ease;
                -moz-transition: all 0.5s ease;
                -o-transition: all 0.5s ease;
                transition: all 0.5s ease;
            }

            #wrapper.toggled {
                padding-left: #{sidebar_width};
            }

            #sidebar-wrapper {
                z-index: 1000;
                position: fixed;
                left: 0; /* #{sidebar_width}; */
                width: 0;
                height: 100%;
                padding-top: 65px;
                margin-left: 0; /* -#{sidebar_width}; */
                overflow-y: auto;
                background: #555;
                -webkit-transition: all 0.5s ease;
                -moz-transition: all 0.5s ease;
                -o-transition: all 0.5s ease;
                transition: all 0.5s ease;
            }

            #wrapper.toggled #sidebar-wrapper {
                margin-left: -#{sidebar_width}; /* width: #{sidebar_width}; */
            }

            #page-content-wrapper {
                width: 100%;
                padding: 15px;
            }

            #wrapper.toggled #page-content-wrapper {
                position: absolute;
                margin-right: -#{sidebar_width};
            }

            /* Sidebar Styles */

            .sidebar-nav {
                position: absolute;
                top: 0;
                width: #{sidebar_width};
                margin: 0;
                padding: 0;
                list-style: none;
            }

            .sidebar-nav li {
                text-indent: 20px;
                line-height: 40px;
            }

            .sidebar-nav li a {
                display: block;
                text-decoration: none;
                color: #bbb;
            }

            .sidebar-nav li a:hover {
                text-decoration: none;
                color: #fff;
                background: rgba(255,255,255,0.2);
            }

            .sidebar-nav li a:active,
            .sidebar-nav li a:focus {
                text-decoration: none;
            }

            .sidebar-nav > .sidebar-brand {
                height: 65px;
                font-size: 18px;
                line-height: 60px;
            }

            .sidebar-nav > .sidebar-brand a {
                color: #999999;
            }

            .sidebar-nav > .sidebar-brand a:hover {
                color: #fff;
                background: none;
            }

            @media(min-width:768px) {
                #wrapper {
                    padding-left: #{sidebar_width};
                }

                #wrapper.toggled {
                    padding-left: 0;
                }

                #sidebar-wrapper {
                    width: #{sidebar_width};
                }

                #wrapper.toggled #sidebar-wrapper {
                    /* width: 0; */
                }

                #page-content-wrapper {
                    padding: 20px;
                }

                #wrapper.toggled #page-content-wrapper {
                    position: relative;
                    margin-right: 0;
                }
            }
            """
        jade: """
            form#listen-to-menu-change
            #sidebar-wrapper
                ul.sidebar-nav
                    +Template.dynamic(template=template)
            """
        events:
            'reset #listen-to-menu-change': (event) ->
                navbar_menu = Session.get 'sidebar.navbar-menu'
                console.log navbar_menu
        helpers:
            template: -> 'sidebar_' + ( Session.get 'sidebar.navbar-menu' or 'home' )
        
    page_nav:
        jade: """
            ul#page-nav
                li: a Hello
                li: a World
                li: a This
                li: a Wesite
                li: a Menu
            """

    __style:
        stylus: """
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

  



