theme =
    clean:
        font_family:            "'PT Sans', sans-serif"
        font_weight:            200
        backgound_color:        '#ccc'
        navbar:
            style:              'fixed-top'
            height:             '50px'
            color:              '#999'
            border:             '1px'
            border_color:       '#fff'
            background_color:   '#eee'
            login:
                width:          '100px'
                dropdown:
                    width:      '190px'
            dropdown:
                width:          '240px'
                padding:        '25px'
                a:
                    height:     '24px'
                    hover:      '#eee'
            text:
                color:          '#888'
                font_size:      '10px'
                height:         '20px'
                width:          '80px'
            hover:
                color:              'black'
                background_color:   '#eee'
            focus:
                color:              'black'
                background_color:   'white'

theme_clean =
    __theme:
        styl$: '''
            
            .tooltip
                width 300px
            .tooltip-inner
                width 100%
                text-align left
                color white
                background-color green
            li.selected
                background-color #a4c5ff
            .container-fluid#main-body
                padding-top 70px
            .fa
                width 10px
                height 10px
            '''
