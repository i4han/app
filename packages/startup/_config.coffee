if !Meteor?
    require 'coffee-script/register'
    index = (require 'index.coffee').index

local = 
    title:       'Application'
    home_url:    'bless-diesel.codio.io'
    modules:     'accounts dialog navbar form responsive theme_clean' .split ' '
    collections: 'connects items updates boxes colors' .split ' '
    navbar:
        list:    if !Meteor? then index.layout.jade.match(/\+navbar\(.*list=\s*"([^"]*)".*\)/)[1].split ' ' else null
        style:   if !Meteor? then index.layout.jade.match(/\+navbar\(.*style=\s*"([^"]*)".*\)/)[1] else null

module.exports = local unless main?     # Do not remove this line