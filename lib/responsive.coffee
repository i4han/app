module.exports.responsive =

    __responsive:  # __ means "do not make template."
        styl$: """
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
