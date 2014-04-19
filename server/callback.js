var _ = Npm.require('underscore');
var Fiber = Npm.require('fibers');
var express = Npm.require( 'express' );
var request = Npm.require( 'request' );

var Connects = new Meteor.Collection( 'connects' );
var Updates = new Meteor.Collection( 'updates' );
var Items = new Meteor.Collection( 'items' );

var instagram_update = function( req, res ) {
    
    _.each( req.body, function (update) {
        update = __.flatten( update )
        _.extend( update,  { service:'Instagram' } );
        __.renameKeys( update, { object_id: 'instagram_user_id' });
        delete update['object'];
        __.log( 'update:\n' + __.prettyJSON(update) );
        Fiber( function () {
            Updates.insert( update );
            var connect = Connects.find({instagram_user_id:update.instagram_user_id}).fetch()[0]
            var media_url = Config.instagram.media_url( update.media_id, connect.access_token );
            __.log( 'media_url:' + media_url );
            request.get( media_url, function ( error, response, body ) {
                var data = JSON.parse( body ).data
                var image = data.images.standard_resolution;
                _.extend( image, {
                    type: data.type,
                    service: 'Instagram',
                    location: data.location,
                    created_time: data.created_time,
                    user_id: connect.user_id,
                    instagram_user_id: connect.instagram_user_id,
                    media_id: update.media_id,
                    access_token: connect.access_token
                });
                __.log( 'image:\n' + __.prettyJSON(image) );
                Fiber( function () {
                    Items.insert( image );
                }).run();
            });
        }).run();
    });
    res.status(204)
}

var instagram_oauth = function ( req, res ) {
    request.post({
        url: Config.instagram.request_url,
        body: __.queryString({
            code: req.query.code,
            grant_type: Config.instagram.grant_type,
            client_id: Config.instagram.client_id,
            client_secret: Config.instagram.client_secret,
            redirect_uri: Config.instagram.redirect_uri( req.query.user_id )
        })
        }, function ( error, response, body ) {
            var ejson = EJSON.parse( body );
            ejson = __.flatten( ejson );
            _.extend( ejson, { user_id:req.query.user_id, service:'Instagram' } );
            __.renameKeys( ejson, { id: "instagram_user_id" });
            Fiber( function () {
                Connects.insert( ejson );
            }).run();
    });
    res.redirect( Config.instagram.final_url );
}

Sat.init();
var app = express();
app.use(express.json()); 
app.post( Config.instagram.callback_path, function(req, res) {
    __.log( 'Raw body:\n' + __.prettyJSON( req.body ) );
    var command = req.query.command;
    if ( command === 'update' ) {
        instagram_update( req, res );
    }
});

app.get( Config.instagram.callback_path, function( req, res ) {
    var command = req.query.command;
    if ( found = /^([^=?]*)\?([^=?]*)=([^=?]*)$/g.exec(command) ) { 
        command = found[1]; // To fix Instagram's bug ?command=update?hub.challenge...
        req.query[ found[2] ] = found[3];
    }
    if ( command === 'oauth' ) {
        instagram_oauth( req, res );
    } else if ( req.query['hub.mode'] ) {
        __.log( req.query['hub.mode'] + ':' + req.query['hub.challenge'] );
        res.send( req.query['hub.challenge'] );
    }
});

app.listen( Config.callback_port );
