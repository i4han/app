module.exports.content =

    home:
        router: path: '/'
        jade: """
            .row
                h1 Any... Title
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

            
            
    popover_name:
        jade: """
            ul 
                li Write your name.
                li No longer then 12 letters.
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



    color_list:
        jade: """
            ul
                each colors
                    +color_info
                else
                    | No colors yet.
            button.btn.btn-primary Like
            """
        created: -> 
            db.Colors = new Meteor.Collection 'colors' if !db.Colors?
            Meteor.subscribe 'colors'
        events:
            'click button': -> db.Colors.update Session.get( 'session_color' ), $inc: likes: 1 
        colors: -> db.Colors.find {}, sort: likes: -1, name: 1

        
    color_info:
        jade: """
            li(class="{{maybe_selected}}") {{name}} {{likes}} 
            """
        events:
            'click': -> Session.set 'session_color', this._id
        maybe_selected: -> if Session.equals 'session_color', this._id then 'selected' else 'not_selected'


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


    __x3d:
        router: {}
        less: """
            .controls {
                position: absolute;
                padding: 10px;
                z-index: 10;
            }            
            x3d {
                height: 500px;
                width: 800px;
                border: 0
            }            
            .swatch {
                width: 40px;
                height: 40px;
                margin: 0 5px 5px 0;
                border: 2px solid transparent;            
                display: inline-block;
                cursor: pointer;            
                &.active {
                    border-color: black;
                }
            }
            """
        HTML: """
            <div class="controls">
                {{#each colors}}
                    <div class="swatch {{#if active}}active{{/if}}" style="background-color: {{this}}"></div>
                {{/each}}
            </div>
            <x3d>
                <scene> 
                    <navigationinfo type="turntable"></navigationinfo>
                    <viewpoint position="8.19 12.33 19.5" orientation="-0.834 0.55 0 0.65"></viewpoint>
                    <transform rotation="-1.5707 0 0 1.5707">
                        <shape>
                            <appearance><material diffuseColor="#4A9"></material></appearance>
                            <plane size="20 20"></plane>
                        </shape>
                    </transform>
                    {{#each boxes}}
                        <transform translation="{{x}} {{y}} {{z}}">
                        <shape id="{{_id}}">
                            <appearance><material diffuseColor="{{color}}" ambientIntensity="0.1"></material></appearance>
                            <box size="1 1 1"></box>
                        </shape>
                        </transform>
                    {{/each}}
                </scene>
            </x3d>
            """
        created: ->
            _.Boxes = Boxes = new Meteor.Collection 'boxes' if !_.Boxes
        helpers:
            boxes: -> _.Boxes.find()
            active: -> this.valueOf() == Session.get "color"
            colors: ["#c2892b", "#e91d45", "#30d02c", "#1d57e9", "#9414c9", "#fee619"]
        events:
            "click .swatch": ->
                console.log this
                Session.set "color", this.valueOf()
            "mousedown x3d": ( event ) ->
                console.log 'Mouse down'
                this.dragged = false
            "doubleclick x3d": ( event ) ->
                _.Boxes.insert
                    color: Session.get "color"
                    x: Math.floor(event.worldX + event.normalX / 2) + 0.5
                    y: Math.floor(event.worldY + event.normalY / 2) + 0.5
                    z: Math.floor(event.worldZ + event.normalZ / 2) + 0.5
            "mousemove x3d": ->
                console.log 'Mouse move'
                this.dragged = true
            "mouseup shape": ( event ) ->
                console.log 'Mouseup shape'
                if ( !this.dragged && event.button == 1 )
                    _.Boxes.insert
                        color: Session.get "color"
                        x: Math.floor(event.worldX + event.normalX / 2) + 0.5
                        y: Math.floor(event.worldY + event.normalY / 2) + 0.5
                        z: Math.floor(event.worldZ + event.normalZ / 2) + 0.5
                else if ( !this.dragged )
                    _.Boxes.remove(event.currentTarget.id)

                                                             
