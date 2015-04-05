
Package.describe({
    summary: 'Satellite framework for Meteor.',
    version: "0.1.3",
    documentation: null
});

Package.on_use( function (api) {
    api.use('underscore');
    api.use('jquery');
    api.use('isaac:settings@0.1.0');
    api.use('isaac:intl-tel-input@0.1.0')
    api.use('isaac:masonry');
    api.use('isaac:moment');
    api.use('isaac:x@0.2.12');
    api.add_files( 'config.js',     ['client', 'server'] );
    api.add_files( 'sat.coffee.js', ['client', 'server'] );
    api.add_files( 'sat.js',        ['client', 'server'] );

    api.export( 'x',        ['client', 'server'] );    
    api.export( 'db',       ['client', 'server'] );
    api.export( 'Sat',      ['client', 'server'] );
    api.export( 'Settings', ['client', 'server'] );
    api.export( 'Pages',    ['client', 'server'] );
    api.export( 'Config',   ['client', 'server'] );
    api.export( 'module',   ['client', 'server'] );
});
