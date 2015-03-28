if (typeof x === "undefined" || x === null) {
  global.x = {
    $: {}
  };
}

if (typeof Meteor === "undefined" || Meteor === null) {
  module.exports.x = x;
}

x.extend = function(object, properties) {
  var key, val;
  for (key in properties) {
    val = properties[key];
    object[key] = val;
  }
  return object;
};

x.capitalize = function(str) {
  return str[0].toUpperCase() + str.slice(1);
};

x.isLowerCase = function(char, index) {
  var _ref;
  return ('a' <= (_ref = char[index]) && _ref <= 'z');
};

x.isString = function(str) {
  return (str != null) && 'string' === typeof str && str.length > 0;
};

x.isVisible = function(v) {
  if ('function' === typeof v) {
    return v();
  } else if (false === v) {
    return false;
  } else {
    return true;
  }
};

x.isAlphabet = function(str) {
  return /^[a-z]+$/i.test(str);
};

x.isDigit = function(str) {
  return /^[0-9]+$/.test(str);
};

x.parseValue = function(value) {
  if ('number' === typeof value) {
    return value.toString() + 'px';
  } else if ('string' === typeof value) {
    return value;
  } else if ('function' === typeof value) {
    return value();
  } else {
    return value;
  }
};

x.timeout = function(time, func) {
  return Meteor.setTimeout(func, time);
};

x.o = function(obj, depth) {
  if (depth == null) {
    depth = 1;
  }
  return ((Object.keys(obj)).map(function(key) {
    var value;
    value = obj[key];
    if (x.isAlphabet(key)) {
      key = x.toDash(key);
    }
    return (Array(depth).join('    ')) + ('object' === typeof value ? [key, x.o(value, depth + 1)].join('\n') : '' === value ? key : '' === key || x.isDigit(key) ? x.parseValue(value) : key + ' ' + x.parseValue(value));
  })).join('\n');
};

x.toDash = function(str) {
  if (str != null) {
    return str.replace(/([A-Z])/g, function($1) {
      return '-' + $1.toLowerCase();
    });
  } else {
    return null;
  }
};

x.query = function() {
  return Iron.Location.get().queryObject;
};

x.hash = function() {
  return ((Iron.Location.get().hash.slice(1).split('&')).map(function(a) {
    return a.split('=');
  })).reduce((function(p, c) {
    p[c[0]] = c[1];
    return p;
  }), {});
};

x.repeat = function(str, times) {
  return Array(times + 1).join(str);
};

x.queryString = function(obj, delimeter) {
  var i;
  if (delimeter == null) {
    delimeter = '&';
  }
  return ((function() {
    var _results;
    _results = [];
    for (i in obj) {
      _results.push(encodeURIComponent(i) + "=" + encodeURIComponent(obj[i]));
    }
    return _results;
  })()).join(delimeter);
};

x.decode = function(str, code, repeat) {
  var decode;
  decode = encodeURIComponent(code);
  return str.replace(new RegExp("(?:" + decode + "){" + repeat + "}(?!" + decode + ")", 'g'), x.repeat(code, repeat));
};

x.saveMustache = function(str) {
  return x.decode(x.decode(str, '{', 2), '}', 2);
};

x.trim = function(str) {
  if (str != null) {
    return str.trim();
  } else {
    return null;
  }
};

x.capitalize = function(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
};

x.dasherize = function(str) {
  return str.trim().replace(/([A-Z])/g, "-$1").replace(/[-_\s]+/g, "-").toLowerCase();
};

x.prettyJSON = function(obj) {
  return JSON.stringify(obj, null, 4);
};

x.getValue = function(id) {
  var element;
  element = document.getElementById(id);
  if (element) {
    return element.value;
  } else {
    return null;
  }
};

x.trimmedValue = function(id) {
  var element;
  element = document.getElementById(id);
  if (element) {
    return element.value.replace(/^\s*|\s*$/g, "");
  } else {
    return null;
  }
};

x.reKey = function(obj, oldName, newName) {
  if (obj.hasOwnProperty(oldName)) {
    obj[newName] = obj[oldName];
    delete obj[oldName];
  }
  return this;
};

x.slice = function(str, tab, indent) {
  if (tab == null) {
    tab = 1;
  }
  if (indent == null) {
    indent = '    ';
  }
  return (((str.replace(/~\s+/g, '')).split('|')).map(function(s) {
    return s = 0 === s.search(/^(<+)/) ? s.replace(/^(<+)/, Array(tab = Math.max(tab - RegExp.$1.length, 1)).join(indent)) : 0 === s.search(/^>/) ? s.replace(/^>/, Array(++tab).join(indent)) : s.replace(/^/, Array(tab).join(indent));
  })).join('\n');
};

x.insertTemplate = function(page, id, data) {
  if (data == null) {
    data = {};
  }
  $('#' + id).empty();
  return Blaze.renderWithData(Template[page], Object.keys(data).length ? data : Template[page].helpers, document.getElementById(id));
};

x.currentRoute = function() {
  return Router.current().route.getName();
};

x.render = function(page) {
  return Template[page].renderFunction().value;
};

x.renameKeys = function(obj, keyObject) {
  return _.each(_.keys(keyObject, function(key) {
    return x.reKey(obj, key, keyObject[key]);
  }));
};

x.repeat = function(pattern, count) {
  var result;
  if (count < 1) {
    return '';
  }
  result = '';
  while (count > 0) {
    if (count & 1) {
      result += pattern;
    }
    count >>= 1;
    pattern += pattern;
  }
  return result;
};

x.deepExtend = function(target, source) {
  var prop;
  for (prop in source) {
    if (prop in target) {
      x.deepExtend(target[prop], source[prop]);
    } else {
      target[prop] = source[prop];
    }
  }
  return target;
};

x.flatten = function(obj, chained_keys) {
  var flatObject, i, j, toReturn, _i, _j, _len, _len1;
  toReturn = {};
  for (_i = 0, _len = obj.length; _i < _len; _i++) {
    i = obj[_i];
    if (typeof obj[i] === 'object') {
      flatObject = x.flatten(obj[i]);
      for (_j = 0, _len1 = flatObject.length; _j < _len1; _j++) {
        j = flatObject[_j];
        if (chained_keys) {
          toReturn[i + '_' + j] = flatObject[j];
        } else {
          toReturn[j] = flatObject[j];
        }
      }
    } else {
      toReturn[i] = obj[i];
    }
  }
  return toReturn;
};

x.position = function(obj) {
  return Meteor.setTimeout(function() {
    return $('#' + obj.parentId + ' .' + obj["class"]).css({
      top: obj.top,
      left: obj.left,
      position: 'absolute'
    });
  }, 200);
};

x.contentEditable = function(id, func) {
  var $cloned;
  $cloned = void 0;
  return $('#' + id).on('focus', '[contenteditable]', function() {
    $(this).data('before', $(this).html());
    return $(this);
  }).on('blur keyup paste input', '[contenteditable]', function() {
    $(this).data('before', $(this).html());
    if ($(this).data('before') !== $(this).html()) {
      console.log('edited');
      func(this);
    }
    return $(this);
  }).on('scroll', '[contenteditable]', function(event) {
    $(this).scrollTop(0);
    event.preventDefault();
    return false;
  }).on('keydown', '[contenteditable]', function() {
    var zIndex;
    if (!$cloned) {
      zIndex = $(this).css('z-index');
      if (parseInt(zIndex, 10) === NaN) {
        $(this).css({
          'z-index': zIndex = 10
        });
      }
      $cloned = $(this).clone();
      $cloned.css({
        'z-index': zIndex - 1,
        position: 'absolute',
        top: $(this).offset().top,
        left: $(this).offset().left,
        overflow: 'hidden',
        outline: 'auto 5px -webkit-focus-ring-color'
      });
      $(this).before($cloned);
    } else {
      $cloned.html($(this).html());
    }
    console.log($cloned.css({
      opacity: 1
    }));
    console.log($(this).css({
      overflow: 'visible',
      opacity: 0
    }));
    return Meteor.setTimeout((function(_this) {
      return function() {
        $(_this).css({
          overflow: 'hidden',
          opacity: 1
        });
        return $cloned.css({
          opacity: 0
        });
      };
    })(this), 200);
  });
};

x.scrollSpy = function(obj) {
  var $$;
  $$ = $('.scrollspy');
  $$.scrollSpy();
  return ['enter', 'exit'].forEach(function(a) {
    return $$.on('scrollSpy:' + a, function() {
      if (obj[a] != null) {
        return obj[a][$(this).attr('id')]();
      }
    });
  });
};

x.calendar = function(fym, id_ym) {
  var $id, action, moment_ym, top, _i, _j, _ref, _ref1, _results, _results1;
  action = moment().format(fym) > id_ym ? 'prepend' : 'append';
  $('#items')[action](DIV({
    "class": 'month',
    id: id_ym
  }));
  moment_ym = moment(id_ym, fym);
  top = $(window).scrollTop();
  ($id = $('#' + id_ym)).append(H2({
    id: id_ym
  }, moment_ym.format('MMMM YYYY')));
  (function() {
    _results = [];
    for (var _i = 1, _ref = parseInt(moment_ym.startOf('month').format('d')); 1 <= _ref ? _i <= _ref : _i >= _ref; 1 <= _ref ? _i++ : _i--){ _results.push(_i); }
    return _results;
  }).apply(this).forEach(function(i) {
    return $id.append(DIV({
      "class": 'everyday empty',
      style: 'visibility:hidden'
    }));
  });
  (function() {
    _results1 = [];
    for (var _j = 1, _ref1 = parseInt(moment_ym.endOf('month').format('D')); 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; 1 <= _ref1 ? _j++ : _j--){ _results1.push(_j); }
    return _results1;
  }).apply(this).forEach(function(i) {
    var id;
    $id.append(DIV({
      "class": 'everyday',
      id: id = id_ym + ('0' + i).slice(-2)
    }));
    x.insertTemplate('day', id, {
      id: id
    });
    x.contentEditable(id, function(_id) {
      var content, doc;
      id = $(_id).parent().attr('id');
      content = $(_id).html();
      switch ($(_id).attr('class')) {
        case 'title':
          console.log('title', id, content);
          if (doc = db.Calendar.findOne({
            id: id
          })) {
            return db.Calendar.update({
              _id: doc._id,
              $set: {
                title: content,
                event: doc.event
              }
            });
          } else {
            return db.Calendar.insert({
              id: id,
              title: content
            });
          }
          break;
        case 'event':
          console.log('event', id, content);
          if (doc = db.Calendar.findOne({
            id: id
          })) {
            return db.Calendar.update({
              _id: doc._id,
              $set: {
                title: doc.title,
                event: content
              }
            });
          } else {
            return db.Calendar.insert({
              id: id,
              event: content
            });
          }
      }
    });
    return ['title', 'event'].forEach(function(s) {
      return $("#" + id + " > ." + s).attr('contenteditable', 'true');
    });
  });
  if ('prepend' === action) {
    x.timeout(10, function() {
      return $(window).scrollTop(top + $id.outerHeight());
    });
    return $('#top').data({
      id: id_ym
    });
  } else {
    return $('#bottom').data({
      id: id_ym
    });
  }
};

x.list = function(what) {
  return ((what = 'string' === typeof what ? what.split(' ') : Array.isArray(what) ? what : []).map(function(a) {
    return "." + a + " {{" + a + "}}";
  })).join('\n');
};

x.sidebar = function(list, id) {
  if (id == null) {
    id = 'sidebar_menu';
  }
  return {
    list: list,
    jade: function() {
      return x.o({
        'each items': {
          '+menu_list': ''
        }
      });
    },
    helpers: {
      items: function() {
        return list.map(function(a) {
          return {
            page: a,
            id: id
          };
        });
      }
    }
  };
};

x.assignPopover = function(o, v) {
  o['focus input#' + v] = function() {
    return $('input#' + v).attr('data-content', x.render('popover_' + v)).popover('show');
  };
  return o;
};

x.popover = function(list) {
  return list.reduce((function(o, v) {
    return x.assignPopover(o, v);
  }), {});
};

x.log = function() {
  return (arguments !== null) && ([].slice.call(arguments)).concat(['\n']).map(function(str) {
    if (Meteor.isServer) {
      return fs.appendFileSync(Config.log_file, str + ' ');
    } else {
      return console.log(str);
    }
  });
};

(typeof window !== "undefined" && window !== null) && ('DIV H2 BR'.split(' ')).map(function(a) {
  return window[a] = function(obj, str) {
    if (str != null) {
      return HTML.toHTML(HTML[a](obj, str));
    } else {
      return HTML.toHTML(HTML[a](obj));
    }
  };
});
