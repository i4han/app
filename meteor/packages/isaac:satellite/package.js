
Package.describe({
    summary: 'Satellite: framework for Meteor in coffeescript.',
    version: '0.1.10',
    documentation: null
});

Package.on_use( function (api) {
    api.use('jquery@1.0.1');
    api.use('isaac:settings@0.1.5');
    api.use('isaac:intl-tel-input@0.1.3');
    api.use('isaac:masonry@0.0.1');
    api.use('isaac:moment@0.0.1');
    api.use('isaac:x@0.2.31');
//    api.add_files( 'config.js',     ['client', 'server'] );
//    api.add_files( 'sat.js',        ['client', 'server'] );
    api.add_files( 'satellite.coffee.js', ['client', 'server'] );

    api.export( 'x',        ['client', 'server'] );    
    api.export( 'db',       ['client', 'server'] );
//    api.export( 'Sat',      ['client', 'server'] );
    api.export( 'Settings', ['client', 'server'] );
    api.export( 'Pages',    ['client', 'server'] );
//    api.export( 'Config',   ['client', 'server'] );
    api.export( 'module',   ['client', 'server'] );
});
