
if Meteor.isServer
    methods = {}
    x.keys(Settings).map (k) -> x.isObject(Settings[k]) and x.keys(Settings[k]).map (l) ->
        Skl = Settings[k][l]
        'string' == typeof Skl.meteor_method and methods[Skl.meteor_method] = (o) ->
            HTTP.call Skl.method, Skl.url, x.interpolateOO Skl.options, o
    Meteor.methods methods
else if Meteor.isClient
	window? and ('DIV H2 BR'.split ' ').map (a) -> window[a] = (obj, str) -> 
		if str? then HTML.toHTML HTML[a] obj, str else HTML.toHTML HTML[a] obj

