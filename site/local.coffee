index_file = 'index'
if !Meteor?
    require 'coffee-script/register'
    index = (require index_file + '.coffee')[index_file]   # used by collect 
    if main?
        T = theme.clean
        T.navbar.height = '50px'

local = 
    title:       'Application'
    index_file:  index_file
    home_url:    'bless-diesel.codio.io'
    modules:     'accounts menu ui responsive' .split ' '
    collections: 'connects items updates boxes colors' .split ' '
    $: {
        theme:   T
        font_family: T.font_family
        font_weight: T.font_weight
        navbar:
            list:    ['home', 'profile', 'connect', 'help'].map (a) -> path:a, label:index[a].label 
            style:   'fixed-top'
            height:  T.navbar.height
            color:   T.navbar.color
            border:  T.navbar.border
            border_color:    T.navbar.border_color
            login:
                width:       T.navbar.login.width
                dropdown:
                    width:   T.navbar.login.dropdown.width
            dropdown:
                width:       T.navbar.dropdown.width
                padding:     T.navbar.dropdown.padding
                a:
                    height:  T.navbar.dropdown.a.height
                    hover:
                        background_color: T.navbar.dropdown.a.hover
            text:
                color:     T.navbar.text.color
                font_size: T.navbar.text.fontsize
                height:    T.navbar.text.height
                width:     T.navbar.text.width
            hover:
                color:            T.navbar.hover.color
                background_color: T.navbar.hover.background_color
            focus:
                color:            T.navbar.focus.color
                background_color: T.navbar.focus.background_color
        end: undefined } if !Meteor? and main?              

module.exports = local  #exclude
