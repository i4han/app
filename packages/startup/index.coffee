module.exports.index =

    home:
        router: path: '/'
        jade: (Config) -> 
            """
            .row
                .col-md-1
                .col-md-8
                    h1 #{Config.title}
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
            # $container.masonry itemSelector: '.item', columnWidth: 332
        helpers:
            items: -> db.Items.find {}, sort: created_time: -1
            title: -> Config.title
        stylus: """
            #items > .item 
                background-color #fff
                width 320px
                height 320px
                float left
                border 1px solid #999
                margin 6px

            if 0 
                transform rotateY( 45deg )
                -webkit-transform rotateY( 45deg )
            """

        
    item:
        jade: """img(src="{{url}}" height="320" width="320")"""
        
    about:
        router: {}
        jade: """
            .row
                +x3d
            .primary-content
                +hello
                br.double-line
                +dialog
            .primary-content
                +color_list
            """
        rendered: ->
            _.each [1..20], (i) -> $container.append( $("""<div id="tile-#{i}" class="tile box"><h2>Tile #{i}</h2></div>""") ) 
            $('.tile').on 'scrollSpy:enter', -> console.log 'enter:', $(this).attr 'id' 
            $('.tile').on 'scrollSpy:exit', -> console.log 'exit:', $(this).attr 'id' 
            $('.tile').scrollSpy()
        stylus: """
            .tile
                width 160px
                float left 
                border 1px solid #999
                margin 6px
            """
        
    profile:
        router: {}
        jade: """
            .primary-content    
                .col-sm-4
                .col-sm-6
                    br.double-line
                    each fields
                        +formField
                        br.half-line
                .col-sm-2
                    br  
            """
        fields: -> [
            title: 'Your name'
            label: 'Name',   icon: 'user'
        ,
            title: 'Mobile Phone Number'
            label: 'Mobile', icon: 'mobile'
        ,
            title: 'Your home Zip code' 
            label: 'Zip',    icon: 'envelope' ]
        events:
            'focus input#name': -> $('input#name').attr('data-content',  Template['popover_name'].render().value).popover('show')

            
            
            
                
    help:
        router: {}
        jade: """
            .primary-content
                .h2 Debug..  
            .primary-content#debug
            """
        rendered: ->
            container = $('#debug')
            _.each _.keys( Pages ), ( name ) ->
                container.append( $("<h2>#{name}</h2>") )         
                _.each _.keys( Pages[name] ), ( key ) ->
                    container.append( $("<h3>#{key}</h3><pre>#{Pages[name][key]}</pre>") ) 


    connect:
        router: {}
        jade: """
            | Connect
            br.single-line
            a(href="{{instagram_connect}}") 
                | Connect with Instagram
            input.btn.btn-default(type="button" value="Click")
            """
        helpers:
            instagram_connect: -> Config.instagram.oauth_url + '?' + __.queryString
                client_id: Config.instagram.client_id
                redirect_uri: Config.instagram.redirect_uri Meteor.userId()
                response_type: Config.instagram.response_type

        events:
            'click input': -> console.log Router.current().route.name
                                                             

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
                
