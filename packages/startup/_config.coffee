if !Meteor?
    require 'coffee-script/register'
    index = (require 'index.coffee').index

local = 
    title:       'Application'
    home_url:    'bless-diesel.codio.io'
    modules:     'accounts dialog navbar form responsive theme_clean' .split ' '
    collections: 'connects items updates boxes colors' .split ' '
    $:
        navbar:
            list:    ('home|Home profile|Profile connect|Connect help|Help'.split ' ').map (a) -> a.split '|'
            style:   'fixed-top'
            height:  '50px'
            color:   '#777'
            border:  '1px'
            border_color:  'black'
            login:
                width: '100px'
                dropdown:
                    width: '250px'
                    padding: '25px'
                    a:
                        height: '30px'
                        hover:
                            background_color: '#eee'
            text:
                color:     '#888'
                font_size: '10px'
                height:    '20px'
                width:     '80px'
            hover:
                color:            'black'
                background_color: 'white'

module.exports = local unless main?     # Do not remove this line