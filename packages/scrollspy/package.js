
Package.describe({ summary: 'Detecting enter/exit of elements in the viewport when the user scrolls.' });

Package.on_use( function (api) {
    api.use('jquery');
    api.add_files( 'scrollspy.js', 'client' );
});
