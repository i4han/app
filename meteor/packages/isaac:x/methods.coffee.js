var methods, obj;

if (Meteor.isServer) {
  methods = {};
  obj = Meteor.settings["private"];
  x.keys(obj).map(function(k) {
    return x.keys(obj[k]).map(function(l) {
      var it;
      it = obj[k][l];
      return 'string' === typeof it.meteor_method && (methods[it.meteor_method] = function(o) {
        var options;
        options = it.options;
        x.isEmpty(o) || x.keys(options).map(function(m) {
          return options[m] = x.fillObj(options[m], o);
        });
        console.log(options);
        return HTTP.call(it.method, it.url, options);
      });
    });
  });
  console.log('methods', methods);
  Meteor.methods(methods);
} else if (Meteor.isClient) {
  (typeof window !== "undefined" && window !== null) && ('DIV H2 BR'.split(' ')).map(function(a) {
    return window[a] = function(obj, str) {
      if (str != null) {
        return HTML.toHTML(HTML[a](obj, str));
      } else {
        return HTML.toHTML(HTML[a](obj));
      }
    };
  });
}
