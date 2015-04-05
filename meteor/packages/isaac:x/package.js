
Package.describe({ 
    summary: 'x tools',
    version: "0.2.12",
    documentation: null
});

Package.on_use( function (api) {
    api.use('isaac:settings@0.1.0');
//    api.use('isaac:scrollspy@0.0.1');

    api.add_files( 'x.js',        ['client', 'server'] );
    api.add_files( 'x_client.js', 'client' );
    api.add_files( 'x.coffee.js', ['client', 'server'] );
    api.add_files( 'x_jquery.js', 'client' );
    api.export( 'x',      ['client', 'server'] );    
    api.export( 'db',     ['client', 'server'] );    
    api.export( 'Pages',  ['client', 'server'] );    
    api.export( 'Settings',['client', 'server'] ); 
//    api.export( 'Config', ['client', 'server'] );    
    api.export( 'Sat',    ['client', 'server'] );    
    api.export( 'module', ['client', 'server'] );    
});
