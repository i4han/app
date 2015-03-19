#!/usr/bin/env coffee

local = 
    title:       'Application'
    home_url:    'circus-baboon.codio.io'
    index_file:  'index'
    other_files: []
    modules:     'accounts menu ui responsive' .split ' '
    collections: 'connects items updates title event' .split ' '
    theme:       'clean'

module.exports = local if !main?
