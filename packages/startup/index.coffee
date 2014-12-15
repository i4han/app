module.exports.index =

    layout:
        jade: """
            +navbar(list="home|Home profile|Profile connect|Connect help|Help" style="fixed-top") 
            .content
                +br(height='54px')
                +yield
            .footer
                +footer
            """
        head: (Config) -> 
            """
            title #{Config.title}
            link(href="https://fonts.googleapis.com/css?family=PT+Sans:400,700" rel="stylesheet" type="text/css")
            """

    home:
        router: path: '/'
        jade: (Config) -> 
            """
            .row
                .col-md-1
                .col-md-8
                    h1 #{Config.title}
            .row#items
                .col-md-1
                .col-md-8
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
        stylus: """
            #items > .item 
                background-color #fff
                width 320px
                height 320px
                float left
                border 1px solid #999
                margin 6px
                transform rotateY( 45deg )
                -webkit-transform rotateY( 45deg )
            """
        
    item:
        jade: """img(src="{{url}}" height="320" width="320")"""
        
    about:
        router: {}
        jade: """
            .row
                +hello
                +br(height='36px')
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
            .row 
                .col-sm-2
                .col-sm-4
                    +br(height='36px')
                    each fields
                        +formField
                        +br(height='9px')
            .row &nbsp;
            """
        helpers:
            fields: -> [
                title: 'Your name',           label: 'Name',   icon: 'user'
            ,   
                title: 'Mobile Phone Number', label: 'Mobile', icon: 'mobile'
            ,   
                title: 'Your home Zip code',  label: 'Zip',    icon: 'envelope' ]
        events:
            'focus input#name': -> $('input#name').attr('data-content',  Template['popover_name'].renderFunction().value).popover('show')
            'focus input#mobile': -> $('input#mobile').attr('data-content',  Template['popover_mobile'].renderFunction().value).popover('show')
            'focus input#zip': -> $('input#zip').attr('data-content',  Template['popover_zip'].renderFunction().value).popover('show')
    popover_name:
        jade: """
            ul 
                li Write your name.
                li No longer then 12 letters.
            """
    popover_mobile:
        jade: """
            ul 
                li Write your phone number.
            """
    popover_zip:
        jade: """
            ul 
                li Write your zipcode.
            """
        
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
                                                             


    footer:
        jade: """
            .content
                .row    
                    +br(height='54px')
                    center © Businesses 2014
            """
                
