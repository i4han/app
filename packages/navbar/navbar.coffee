module.exports.navbar =

    navbar:
        jade: (Config) ->
            _ = require 'underscore'
            _.templateSettings = interpolate: /\[(.+?)\]/g
            menu = ''
            Config.$.navbar.list.forEach (list) -> 
                menu += ( _.template """            li: a(href="{{pathFor '[name]'}}") [link]\n""" ) { name:list[0], link:list[1] }                 
            """
            .navbar.navbar-default.navbar-#{Config.$.navbar.style}: .container
                .navbar-left 
                    ul.nav.navbar-nav
            #{menu}
                .navbar-right
                    +login
            """
        styl_compile: (Config) -> """
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

        
    page_nav:
        jade: """
            ul#page-nav
                li: a Hello
                li: a World
                li: a This
                li: a Wesite
                li: a Menu
            """


