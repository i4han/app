module.exports.index =

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


    __dropdownConnect:
        __jade: """
            li.dropdown
                a.dropdown-toggle#download(data-toggle="dropdown") 
                    | Connect 
                    i.fa.fa-chevron-down
                ul.dropdown-menu(aria-labelledby="download")
                    li: a(href="#")
                        | Connect with Facebook
                    li: a(href="#") 
                        | Connect with Google+
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
                
            
            
    __responsive:
        stylus: """
        $desktop_width = 885px
        $desktop_height = 540px
        $tablet_height = 800px
        
        
        @media screen and ( min-width: $desktop_width )
            #footer
                height: 50px
            .footer-content
                width: 200px
                position: absolute
                left: 0
                bottom: 1.0em
        
        @media screen and ( min-width: $desktop_width )
            #hero .packery
                padding-left: 200px
            #hero h1 
                font-size: 140px
                padding-top: 20px
                margin-bottom: 30px
            #hero .tagline 
                font-size: 32px
            #hero .stamp
                position: absolute
                z-index: 2
            #hero .stamp-ackery
                width: 476px
                height: 90px
                left: 294px
                top: 92px
            #hero .stamp-p-top
                width: 95px
                height: 82px
                left: 200px
                top: 70px
            #hero .stamp-p-bottom
                width: 40px
                height: 90px
                left: 200px
                top: 92px
            #hero .stamp-k
                width: 34px
                height: 90px
                left: 459px
                top: 65px
            #hero .stamp-y
                width: 70px
                height: 88px
                left: 675px
                top: 120px
            #hero .stamp-tagline
                width: 494px
                height: 40px
                left: 200px
                top: 239px
        
        @media screen and ( min-width: $tablet_height )
            #content .primary-content
                padding-top: 20px
                padding-bottom: 20px
            #content .primary-content > *
                max-width: 700px
            #content .primary-content .row,
            #content #notification,
            #content #hero-demos
                max-width: 1200px
            .row
                margin-bottom: 0.8em
            .row .cell
                float: left
                width: 48.75%
                margin-right: 2.5%
                margin-bottom: 0
            .lt-ie9 .row .cell
                margin-right: 1.5%
            .row3 .cell
                width: 31.6%
            .row4 .cell
                width: 23.1%
            .row .cell:last-child
                margin-right: 0
        
        @media screen and ( min-width: $desktop_width )
            .primary-content
                padding-left: 200px
                padding-right: 0px
            #page-nav
                position: absolute
                left: 0
                top: 60px
                list-style: none
                padding: 0
                width: 200px
                padding: 20px
            #page-nav li
                display: block
                margin-bottom: 4px
                margin-left: 0
            #page-nav li:after
                content: none
        
        @media screen and ( min-width: $desktop_width ) and ( min-height: $desktop_height )
            #page-nav
                position: fixed
        """

    __theme:
        stylus: """
//
// app.css
//
body
    font-family 'PT Sans', sans-serif
    font-weight 200

.tooltip
    width 300px

.tooltip-inner
    width 100%
    text-align left
    color white
    background-color green

    
.btn
  font-family 'PT Sans'
  width 150px //166
  border 0

.btn-default
  background-color #f8f8f8  

.btn-default 
.btn-primary 
.btn-success 
.btn-info 
.btn-warning 
.btn-danger 
.btn-default:hover
.btn-primary:hover
.btn-success:hover
.btn-info:hover
.btn-warning:hover
.btn-danger:hover
  border 0
  
li.selected
  background-color #a4c5ff


.container-fluid#main-body
  padding-top 70px
  
.half-line
  line-height 0
.single-line
  line-height 18px  
.double-line
  line-height 36px
.triple-line
  line-height 54px


.modal-backdrop
  opacity: 0.50

#login-buttons-reset-password-modal, #login-buttons-enroll-account-modal
  .modal-content
    margin-top: 30%;

.login-buttons-dropdown-align-left
  &#login-buttons + li
    .dropdown-menu
      float: left;
      left: 0;
      right: auto;
      
.login-buttons-dropdown-align-right
  &#login-buttons + li
    .dropdown-menu
      float: right;
      right: 0;
      left: auto;
.or
  text-align: center

#login-buttons
  display: none;

#login-dropdown-list a
  cursor: pointer;

.dropdown-menu
  top 50px
  margin 0px
  font-weight 200
  text-align left
  line-height 20px
  border-radius 1px

  &#logged-in-dropdown
    right 0
    left auto
    width 186px
    padding-left 0px
    padding-right 0px
    padding-top 5px
    padding-bottom 5px

.dropdown-menu > li > a
  font-weight 200

.dropdown-menu-icon
  margin-right 12px

.dropdown-menu-link
  line-height 25px



// login dropdown

li#login-dropdown-list
  float right
  width 100px
  line-height 50px
  display table-cell
  text-align right
  vertical-align middle

  .dropdown
    height 50px

#login-dropdown-list input
#login-dropdown-list input:first-of-type
#login-dropdown-list input:last-of-type
  margin-bottom 0px
  border-top-left-radius 0px
  border-top-right-radius 5px
  border-bottom-left-radius 0px
  border-bottom-right-radius 5px


.fa
  width 10px
  height 10px

"""
