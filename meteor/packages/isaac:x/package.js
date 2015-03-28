
Package.describe({ 
    summary: 'x tools',
    version: "0.1.0",
    documentation: null
});

Package.on_use( function (api) {
    api.add_files( 'x.js',        ['client', 'server'] );
    api.add_files( 'x_client.js', 'client' );
    api.add_files( 'x.coffee.js', ['client', 'server'] );
    api.export(    'x',           ['client', 'server'] );    
});
