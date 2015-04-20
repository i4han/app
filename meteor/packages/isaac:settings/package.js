
Package.describe({ 
    summary: 'Initalizing settings.',
    version: '0.1.9',
    documentation: null
});

Package.on_use( function (api) {
    api.add_files( 'settings.js', ['client', 'server'] );
    api.export( 'x',        ['client', 'server'] );    
    api.export( 'db',       ['client', 'server'] ); 
    api.export( 'Settings', ['client', 'server'] );
    api.export( 'Module',    ['client', 'server'] );    
});
