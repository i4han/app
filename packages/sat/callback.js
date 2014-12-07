var _  = Npm.require('underscore');
var Fiber  = Npm.require('fibers');
var Future = Npm.require('fibers/future');
var express  = Npm.require('express');
var request  = Npm.require('request');

var instagram_update_item = function (update) {
    update = __.flatten( update )
    _.extend( update,  { service:'Instagram' } );
    __.renameKeys( update, { object_id: 'instagram_user_id' });
    delete update['object'];
    Config.redis.set( 'callback:update', JSON.stringify( update ) );
    Fiber( function () {
        db.Updates.insert( update );
        var connect = db.Connects.find({instagram_user_id:update.instagram_user_id}).fetch()[0]
        var media_url = Config.instagram.media_url( update.media_id, connect.access_token );
        Config.redis.set( 'callback:media_url', media_url );
        request.get( media_url, function ( error, response, body ) {
            var data = JSON.parse( body ).data
            var item = data.images.standard_resolution;
            _.extend( item, {
                media_id: update.media_id,
                type:     data.type,
                service: 'Instagram',
                location: data.location,
                created_time: data.created_time,
                user_id:           connect.user_id,
                instagram_user_id: connect.instagram_user_id,
                access_token:      connect.access_token
            });
            Config.redis.set( 'callback:item', JSON.stringify(item) );
            Fiber( function () {
                db.Items.insert( item );
            }).run();
        });
    }).run();
}


var instagram_update = function (req, res) {    
    _.each( req.body, function (update) {
        Config.redis.rpush( 'callback:updates', JSON.stringify(update) );
        Config.redis.sismember('callback:media_id', update.data.media_id, function (err, reply) {
            Config.redis.rpush( 'callback:reply', JSON.stringify(reply) );
            if ( !reply ) {
                Config.redis.sadd( 'callback:media_id', update.data.media_id, function (err) {} );
                instagram_update_item( update );
            }
        });
    });
    res.status(204)
}


var instagram_oauth = function ( req, res ) {
    request.post({
        url: Config.instagram.request_url,
        body: __.queryString({
            code: req.query.code,
            grant_type: Config.instagram.grant_type,
            client_id:  Config.instagram.client_id,
            client_secret: Config.instagram.client_secret,
            redirect_uri:  Config.instagram.redirect_uri( req.query.user_id )
        })
        }, function ( error, response, body ) {
            var connect = __.flatten( EJSON.parse( body ) )
            _.extend( connect, { 
                user_id: req.query.user_id, 
                service: 'Instagram' 
            });
            __.renameKeys( connect, { id: "instagram_user_id" });
            Fiber( function () {
                db.Connects.insert( connect );
            }).run();
    });
    res.redirect( Config.instagram.final_url );
}


var app = express();
// app.use(express.json());

app.post( Config.instagram.callback_path, function(req, res) {
    Config.redis.set( 'callback:rawbody', JSON.stringify( req.body ) );
    var command = req.query.command;
    if ( command === 'update' ) {
        instagram_update( req, res );
    }
    res.send('Post OK.');
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
        Config.redis.set( 'hub.mode', req.query['hub.mode'] );
        Config.redis.set( 'hub.challenge', req.query['hub.challenge'] );
        res.send( req.query['hub.challenge'] );
    }
});

app.listen( Config.callback_port );
