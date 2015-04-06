Package.describe({
  name: 'isaac:intl-tel-input',
  summary: 'Meteor package for https://github.com/Bluefieldscom/intl-tel-input',
  version: '0.1.3',
  documentation: null
});

Package.onUse(function(api) {
  api.versionsFrom('1.0');
  api.use('jquery', 'client');
  api.addFiles([
    'init.js',
    'intl-tel-input/build/js/intlTelInput.js',
    'intl-tel-input/build/img/flags@2x.png',
    'intl-tel-input/build/img/flags.png'
  ], 'client');
});

