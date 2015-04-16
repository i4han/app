
x      = {$:{}};
db     = {};
Pages  = {};
Settings = Meteor.settings;

if (Meteor.isServer) {
} else if (Meteor.isClient) {
	window.call = {}
	window.o = {$:[]}; 

	o.style = document.createElement('style');
	o.style.setAttribute('id', 'satellite');

	o.$.push(function () {
		document.body.appendChild(o.style);
		o.stylesheet = o.style.sheet ? o.style.sheet : o.style.styleSheet;
	});
//    Meteor.call('Settings', function (err, result) {
//        Session.set('Settings', result);
//    });
}
