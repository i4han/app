
if Meteor.isServer
    methods = {}
    obj = Meteor.settings.private
    x.keys(obj).map (k) -> x.keys(obj[k]).map (l) ->
        it = obj[k][l]
        'string' == typeof it.meteor_method and methods[it.meteor_method] = (o) ->
        	options = it.options
        	x.isEmpty(o) or x.keys(options).map (m) -> options[m] = x.fillObj options[m], o
        	console.log options
        	HTTP.call it.method, it.url, options
    console.log 'methods', methods
    Meteor.methods methods
else if Meteor.isClient
	window? and ('DIV H2 BR'.split ' ').map (a) -> window[a] = (obj, str) -> 
		if str? then HTML.toHTML HTML[a] obj, str else HTML.toHTML HTML[a] obj
