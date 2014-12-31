module.exports.layout =

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
