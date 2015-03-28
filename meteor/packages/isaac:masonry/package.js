
Package.describe({ 
    summary: 'Cascading grid layout library.',
    version: '0.0.1',
    documentation: null
});

Package.on_use( function (api) {
    api.use('jquery@1.0.1');
    api.add_files( 'masonry.js', 'client' );
    api.export( 'Masonry',  'client' );
});
