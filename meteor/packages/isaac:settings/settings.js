
x      = {$:{}};
db     = {};
Module   = {};
Settings = Meteor.settings;

if (Meteor.isServer) {
} else if (Meteor.isClient) {
	window.call = {}
	window.style = {}
	window.o = {$:[]}; 

	window.px = function (v) { return String(v) + 'px'; }
	o.style = document.createElement('style');
	o.style.setAttribute('id', 'satellite');
 
	o.$.push(function () {
		document.body.appendChild(o.style);
		o.stylesheet = o.style.sheet ? o.style.sheet : o.style.styleSheet;
	});
}
