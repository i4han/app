module.exports.navbar =

    navbar:
        jade: (Config) ->
            _ = require 'underscore'
            _.templateSettings = interpolate: /\[(.+?)\]/g
            menu = ''
            Config.navbar.list.forEach (list) -> 
                val = list.split '|'
                menu += ( _.template """            li: a(href="{{pathFor '[name]'}}") [link]\n""" ) { name:val[0], link:val[1] } 
                
            """
            .navbar.navbar-default.navbar-#{Config.navbar.style}: .container
                .navbar-left 
                    ul.nav.navbar-nav
            #{menu}
                .navbar-right
                    +loginButtons
            """

        rendered: ->
            console.log Template.currentData().name
            
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
            .navbar-right > li:hover   
            .navbar-nav > li > a:hover
                text-decoration none
                color black
                background-color #eee      
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
            .dropdown-toggle > i.fa-chevron-down
                padding-left 4px
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


