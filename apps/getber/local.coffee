#!/usr/bin/env coffee

local = 
    title:       'Application'
    port_index:	 1 # port order
    index_file:  'index'
    other_files: []
    modules:     'accounts menu ui responsive' .split ' '
    theme:       'clean'


module.exports = local if !main?
