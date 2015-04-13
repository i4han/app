

Router.route '/-/:shorten', (->
	@response.writeHead 301, Location: (switch @params.shorten
		when 'flags.png'    then '/packages/isaac_intl-tel-input/intl-tel-input/build/img/flags.png'
		when 'flags@2x.png' then '/packages/isaac_intl-tel-input/intl-tel-input/build/img/flags@2x.png'
		else Meteor.settings.shortens[@params.shorten] or 'path-not-found') +
		if @params.query then x.addQuery @params.query else ''
	@response.end() 
),  where: 'server'

Router.route '/forward/:target', (->
	v = Meteor.settings.forwards[@params.target].split '.'
	@response.writeHead 301, Location: switch v[1]
		when 'oauth' then x.oauth v[0]
	@response.end()
), where: 'server'

Router.route '/api/ok', where: 'server'
  .get  -> @response.end 'get request\n'
  .post -> @response.end 'post request\n'
  .put  -> @response.end 'put request\n'

#	fs.createReadStream(file).pipe(this.response);
