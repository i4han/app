var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

db.server = function() {
  return Meteor.settings["public"].collections.map(function(collection) {
    console.log(collection);
    db[collection] = new Meteor.Collection(collection);
    db[collection].allow({
      insert: function(doc) {
        return true;
      },
      update: function(userId, doc, fields, modifier) {
        return true;
      },
      remove: function(userId, doc) {
        return true;
      }
    });
    db[collection].deny({
      update: function(userId, doc, fields, modifier) {
        return false;
      },
      remove: function(userId, doc) {
        return false;
      }
    });
    return Meteor.publish(collection, function() {
      return db[collection].find({});
    });
  });
};

db.client = function() {
  return Meteor.settings["public"].collections.map(function(collection) {
    db[collection] = new Meteor.Collection(collection);
    return Meteor.subscribe(collection);
  });
};

Pages.init = function() {
  var pagesInFile;
  delete Pages.init;
  pagesInFile = module.exports;
  return (x.keys(pagesInFile)).map(function(file) {
    var key, val, _ref;
    if (file.slice(0, 2) !== '__') {
      _ref = pagesInFile[file];
      for (key in _ref) {
        val = _ref[key];
        Pages[key] = val;
      }
    }
    return ((x.keys(pagesInFile[file])).filter(function(key) {
      return key.slice(0, 2) === '__';
    })).map(function(name) {
      return delete Pages[name];
    });
  });
};

Sat.init = function() {
  var atRendered, methods, router_map, startup;
  Pages.init();
  if (Meteor.isServer) {
    db.server();
    methods = {};
    (x.keys(Pages)).map(function(name) {
      return (x.keys(Pages[name])).map(function(key) {
        var k, v, _ref, _results;
        if ('methods' === key) {
          _ref = Pages[name][key];
          _results = [];
          for (k in _ref) {
            v = _ref[k];
            _results.push(methods[k] = v);
          }
          return _results;
        }
      });
    });
    return Meteor.methods(methods);
  } else if (Meteor.isClient) {
    db.client();
    Router.configure({
      layoutTemplate: 'layout'
    });
    startup = [];
    router_map = {};
    atRendered = [];
    (x.keys(Pages)).map(function(name) {
      return (x.keys(Pages[name])).map(function(key) {
        var obj;
        if ('startup' === key) {
          return startup.push(Pages[name].startup);
        } else if ('atRendered' === key) {
          obj = x.func(Pages[name].atRendered);
          return (x.keys(obj)).map(function(k) {
            return (x.keys(obj[k])).map(function(l) {
              if ('removeClass' === l) {
                return atRendered.push(function() {
                  return $(k).removeClass(obj[k][l]);
                });
              } else if ('addClass' === l) {
                return atRendered.push(function() {
                  return $(k).addClass(obj[k][l]);
                });
              } else {
                return atRendered.push(function() {
                  return $(k).css(l, x.value(obj[k][l]));
                });
              }
            });
          });
        } else if ('onRendered' === key) {
          return Template[name][key](function() {
            Pages[name][key]();
            return atRendered.map(function(f) {
              return f();
            });
          });
        } else if ('router' === key) {
          return router_map[name] = Pages[name].router;
        } else if (__indexOf.call('eco navbar'.split(' '), key) >= 0) {
          return '';
        } else if (__indexOf.call('events helpers'.split(' '), key) >= 0) {
          return Template[name][key](x.func(Pages[name][key]));
        } else if (__indexOf.call('onCreated onDestroyed'.split(' '), key) >= 0) {
          return Template[name][key](Pages[name][key]);
        }
      });
    });
    Router.map(function() {
      var key, _results;
      _results = [];
      for (key in router_map) {
        _results.push(this.route(key, router_map[key]));
      }
      return _results;
    });
    return Meteor.startup(function() {
      return startup.map(function(func) {
        return func();
      });
    });
  }
};

if (Meteor.isClient) {
  $(function($) {
    var k, _results;
    Sat.init();
    _results = [];
    for (k in x.$) {
      _results.push($.fn[k] = x.$[k]);
    }
    return _results;
  });
} else if (Meteor.isServer) {
  Meteor.startup(function() {
    return Sat.init();
  });
}
