
#include begin

index_file = 'index'
if !Meteor?
    require 'coffee-script/register'
    index = (require index_file + '.coffee')[index_file]   # used by collect 
    
local = 
    title:       'Application'
    home_url:    'bless-diesel.codio.io'
    modules:     'accounts menu ui responsive theme_clean' .split ' '
    collections: 'connects items updates boxes colors' .split ' '
    $:
        navbar:
            list:    ['home', 'profile', 'connect', 'help'].map (a) -> path:a, label:index[a].label if !Meteor?
            style:   'fixed-top'
            height:  '50px'
            color:   '#777'
            border:  '1px'
            border_color:    'black'
            login:
                width:       '100px'
                dropdown:
                    width:   '250px'

            dropdown:
                padding: '25px'
                a:
                    height: '24px'
                    hover:
                        background_color: '#eee'
            text:
                color:     '#888'
                font_size: '10px'
                height:    '20px'
                width:     '80px'
            hover:
                color:            'black'
                background_color: '#eee'
            focus:
                color:            'black'
                background_color: 'white'

    
#include end                

module.exports = local