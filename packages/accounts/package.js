
Package.describe({ summary: 'Accounts for Saterllite.' });

Package.on_use( function (api) {
    api.use('underscore');
    api.use('jquery');
    api.add_files( 'accounts.js', 'client' );

    api.export( 'Login',  'client' );
});