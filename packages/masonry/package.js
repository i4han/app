
Package.describe({ summary: 'Cascading grid layout library.' });

Package.on_use( function (api) {
    api.use('jquery');
    api.add_files( 'masonry.pkgd.js', 'client' );
    api.export( 'Masonry',  'client' );
});
