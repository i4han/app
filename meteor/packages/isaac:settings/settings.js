
x      = { $:{} };
db     = {};
Pages  = {};
Settings = Meteor.settings;

if (Meteor.isServer) {
} else if (Meteor.isClient) {
	window.o = {} 
//    Meteor.call('Settings', function (err, result) {
//        Session.set('Settings', result);
//    });
}
