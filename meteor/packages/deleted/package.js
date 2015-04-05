
Package.describe({ 
    summary: 'intlTelInputUtils',
    version: "0.0.2",
    documentation: null
});

Package.on_use( function (api) {
    api.use('isaac:settings@0.0.13');
    api.add_files( 'intlTelInputUtils.js', 'client' );
    api.export(    'intlTelInputUtils', 'client' );    
});
