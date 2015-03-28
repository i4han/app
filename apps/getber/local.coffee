#!/usr/bin/env coffee

local = 
    title:       'Application'
    port_index:	 1 # port order
    home_url:    'circus-baboon.codio.io'
    index_file:  'index'
    other_files: []
    modules:     'accounts menu ui responsive' .split ' '
    collections: 'Connects Items Updates Calendar User' .split ' '
    theme:       'clean'
    uber_oauth_url:   'https://login.uber.com/oauth/authorize'
    uber_oauth:
        scope:        'request profile history_lite'
        client_id:    'xJsIAYCmEZElqHVLKJyPxVNcXUXqwE_q'
        redirect_uri: 'https://www.getber.com/submit'
        response_type:'token'


module.exports = local if !main?
