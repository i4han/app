Package.describe({
  name: 'isaac:route',
  summary: 'Meteor package for shorten and rest',
  version: '0.1.1',
  documentation: null
});

Package.on_use(function(api) {
  api.use('iron:router@1.0.7');
  api.use('isaac:x@0.2.38');  
  api.addFiles([
    'route.js'
  ], 'server');
//  api.export( '', 'client');
});

