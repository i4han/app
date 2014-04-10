var Fiber = Npm.require('fibers')
var express = Npm.require( 'express' );
var request = Npm.require( 'request' );

var Colors = new Meteor.Collection( 'colors' );
// Meteor.publish( 'colors', function() { Colors.find({}); });
var Profile = new Meteor.Collection( 'profile' );
// Meteor.publish( 'profile', function() { Profile.find(); });
var app = express();

app.get('/callback/instagram/', function( req, res ) {
    var code = req.query.code
    console.log( 'Cookie:' + req.cookies.id );
    request.post({
        url: 'https://api.instagram.com/oauth/access_token/',
        body: _.queryString({
            code: code,
            grant_type: 'authorization_code',
            client_id: 'af97412ac5b94e18af85ced8d55785bd',
            client_secret: '2052d01ca98e478790c6843d34d66a6c',
            redirect_uri: 'http://www.hi16.ca:3003/callback/instagram/'
        })
    }, function ( error, response, body ) {
        Fiber( function () {             
            ejson = {id:'i4han', instagram: EJSON.parse( body )};
            Profile.insert( ejson );
        }).run();
    });
    res.redirect('http://www.hi16.ca/');
});
app.listen(3003);
