module.exports.content =

    home:
        jade: """
            .primary-content
                h1 Title
                +page_nav
            .primary-content
                +hello
                br.double-line
                +dialog
            .primary-content
                +color_list
            .primary-content#blue-box
                section.container#blue
            """
        rendered: ->
            $container = $('#blue')
            _.each [1..20], (i) -> $container.append( $("""<div id="tile-#{i}" class="tile box"><h2>Tile #{i}</h2></div>""") ) 
            $('.tile').on 'scrollSpy:enter', -> console.log 'enter:', $(this).attr 'id' 
            $('.tile').on 'scrollSpy:exit', -> console.log 'exit:', $(this).attr 'id' 
            $('.tile').scrollSpy()
            $container.masonry itemSelector: '.box', columnWidth: 172

        stylus: """
            #blue
              -webkit-perspective 600px            
            #blue > .box
              background-color #f0f0f0 
            if 0 
              transform rotateY( 45deg )
              -webkit-transform rotateY( 45deg )
            .tile
                width 160px
                float left
                border 1px solid #999
                margin 6px
            """


    about:
        jade: """
            .primary-content
                +x3d
            """

        
    profile:
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
        jade: """
            .primary-content
                .h2 Debug  
            .primary-content#debug
            """
        rendered: ->
            container = $('#debug')
            _.each _.keys( Page ), ( file ) ->
                _.each _.keys( Page[file] ), ( page ) ->
                    container.append( $("<h2>#{page}</h2>") )         
                    _.each _.keys( Page[file][page] ), ( key ) ->
                        container.append( $("<h3>#{key}</h3><pre>#{Page[file][page][key]}</pre>") ) 



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
            _.Colors = Colors = new Meteor.Collection 'colors' if !_.Colors
            Meteor.subscribe 'colors'
        events:
            'click button': -> _.Colors.update Session.get( 'session_color' ), $inc: likes: 1 
        colors: -> _.Colors.find {}, sort: likes: -1, name: 1

        
    color_info:
        jade: """
            li(class="{{maybe_selected}}") {{name}} {{likes}} 
            """
        events:
            'click': -> Session.set 'session_color', this._id
        maybe_selected: -> if Session.equals 'session_color', this._id then 'selected' else 'not_selected'


    hello:
        jade: """
            | Hello.
            br.single-line
            input.btn.btn-default(type="button" value="Click")
            """
        events:
            'click input': -> console.log Router.current().route.name


    x3d:
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

                                                             
