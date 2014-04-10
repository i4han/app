var request = require('request');

queryString = function ( obj ) {
    var parts = [];
    for ( var i in obj ) {
        if ( obj.hasOwnProperty( i ) ) {
            parts.push( encodeURIComponent( i ) + "=" + encodeURIComponent( obj[ i ] ) );
        }
    }
    return parts.join( "&" );
}
    request.post({
            url: 'https://api.instagram.com/oauth/access_token/',
            body: queryString({
                code: 'b7b8b650de2c47f890a6e861fab275e9',
                grant_type: 'authorization_code',
                client_id: 'af97412ac5b94e18af85ced8d55785bd',
                client_secret: '2052d01ca98e478790c6843d34d66a6c',
                redirect_uri: 'http://www.hi16.ca:3003/callback/instagram/'
            })
            }, function ( error, response, body ) {
                console.log(body);
                console.log( typeof body );
            }
    );