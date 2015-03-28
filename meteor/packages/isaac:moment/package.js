
Package.describe({ 
	summary: 'Moment.js: Manipulate and display dates',
    version: '0.0.1',
    documentation: null
});

Package.on_use( function (api) {
    api.use('jquery@1.0.1');
    api.add_files( 'moment.js', 'client' );
    api.export(    'moment',    'client' );
});
