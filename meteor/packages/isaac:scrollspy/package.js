
Package.describe({ 
    summary: 'Detecting enter/exit of elements in the viewport when the user scrolls.',
    version: '0.0.1',
    documentation: null
});

Package.on_use( function (api) {
    api.use('jquery@1.0.1');
    api.add_files( 'scrollspy.js', 'client' );
});
