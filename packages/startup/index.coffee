module.exports.index =

    home:
        router: path: '/'
        jade: """
            .row
                h1 {{title}}
            .row#items
                each items
                    .item
                        +item
            """
        created: -> 
            db.Items = new Meteor.Collection 'items' if !db.Items?
            Meteor.subscribe 'items'

        rendered: ->
            $container = $('#items')
            $container.masonry itemSelector: '.item', columnWidth: 332
        items: -> db.Items.find {}, sort: created_time: -1
        stylus: """
            #items > .item 
                background-color #fff
                width 320px
                height 320px
                float left
                border 1px solid #999
                margin 6px
            """
        
    item:
        jade: """img(src="{{url}}" height="320" width="320")"""
        

    layout:
        jade: """
            +navbar
            .content
                br.triple-line
                +yield
            .footer
                +footer
            if 0
                .container-fluid#main-body: .row
            """
        head: (Config) -> 
            """
            title #{Config.title}
            link(href="https://fonts.googleapis.com/css?family=PT+Sans:400,700" rel="stylesheet" type="text/css")
            """
        
    navbar:
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
        jade: """
            .navbar.navbar-default.navbar-fixed-top: .container
                .navbar-left 
                    ul.nav.navbar-nav
                        li: a(href="{{pathFor 'home'}}") Home
                        li: a(href="{{pathFor 'profile'}}") Profile
                        li: a(href="{{pathFor 'connect'}}") Connect
                        li: a(href="{{pathFor 'help'}}") Help
                .navbar-right
                    +loginButtons
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


    footer:
        jade: """
            .content
                .row    
                    br.triple-line
                    center About Help Blog Terms info Businesses © 2014 Hello
            """
                
            
            
