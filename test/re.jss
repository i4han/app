var requestify = require( 'requestify' ); 

    console.log( 'Instagram callback:' + '09418949d23f4669a1d5fe719af91879' );
    requestify.post('https://api.instagram.com/oauth/access_token/', {
        code: '09418949d23f4669a1d5fe719af91879',
        grant_type: 'authorization_code',
        client_id: 'af97412ac5b94e18af85ced8d55785bd',
        client_secret: '2052d01ca98e478790c6843d34d66a6c',
        redirect_uri: 'http://www.hi16.ca:3003/callback/instagram/'
    }).then( function ( response ) {
        console.log( 'Responsed:' + '09418949d23f4669a1d5fe719af91879');    
        _.body = response.getBody()
        res.send( _.body );
    });
    console.log( 'Ready...' + '09418949d23f4669a1d5fe719af91879' );    
