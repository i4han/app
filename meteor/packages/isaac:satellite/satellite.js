// Generated by CoffeeScript 1.8.0
var collections, db_client, db_server;

collections = x.toArray(Meteor.settings["public"].collections);

db_server = function() {
  return collections.map(function(collection) {
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

db_client = function() {
  return collections.map(function(collection) {
    db[collection] = new Meteor.Collection(collection);
    return Meteor.subscribe(collection);
  });
};

Meteor.startup(function() {
  x.keys(module.exports).map(function(file) {
    var key, val, _ref;
    _ref = module.exports[file];
    for (key in _ref) {
      val = _ref[key];
      Pages[key] = val;
    }
    return x.keys(module.exports[file]).filter(function(key) {
      return key.slice(0, 2) === '__';
    }).map(function(name) {
      return delete Pages[name];
    });
  });
  if (Meteor.isServer) {
    db_server();
    return x.keys(Pages).map(function(name) {
      var methods;
      return (methods = Pages[name].methods) && Meteor.methods(methods);
    });
  } else if (Meteor.isClient) {
    db_client();
    Router.configure({
      layoutTemplate: 'layout'
    });
    x.keys(Pages).map(function(name) {
      var _;
      _ = Pages[name];
      _.onStartup && Pages[name].onStartup.call(window);
      _.router && Router.map(function() {
        return this.route(name, Pages[name].router);
      });
      _.events && Template[name].events(x.func(Pages[name].events));
      _.helpers && Template[name].helpers(x.func(Pages[name].helpers));
      _.on$Ready && $(function($) {
        return Pages[name].on$Ready.call(window);
      });
      return ('onCreated onRendered onDestroyed'.split(' ')).forEach(function(d) {
        return _[d] && Template[name][d](function() {
          return Pages[name][d].call(window);
        });
      });
    });
    return $(function($) {
      var k, _results;
      o.$.map(function(f) {
        return f();
      });
      _results = [];
      for (k in x.$) {
        _results.push($.fn[k] = x.$[k]);
      }
      return _results;
    });
  }
});
