
x      = { $:{} };
db     = {};
Pages  = {};
Sat    = {};
Config = {};
// intlTelInputUtils= {};
Settings = Meteor.settings;

if (Meteor.isServer) {
    Meteor.methods({
//        'Settings': function () { 
//            return Meteor.settings; 
//        }
    });
    Settings = Meteor.settings;
} else if (Meteor.isClient) {
//    Meteor.call('Settings', function (err, result) {
//        Session.set('Settings', result);
//    });
}
