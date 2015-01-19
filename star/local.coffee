#!/usr/bin/env coffee

local = 
    title:       'Application'
    home_url:    'circus-baboon.codio.io'
    index_file:  'index'
    other_files: []
    modules:     'accounts menu ui responsive' .split ' '
    collections: 'Connects Items Updates Calendar' .split ' '
    theme:       'clean'

module.exports = local if !main?
