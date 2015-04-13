Package.describe({
  name: 'isaac:absurd',
  summary: 'Meteor package for github /krasimir/absurd',
  version: '0.0.2',
  documentation: null // ready to github
});

Package.on_use(function(api) {
  api.addFiles([
    'absurd.min.js'
  ], 'client');
  api.export( 'Absurd', 'client');    

});

