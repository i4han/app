var calendar_size, date_box_size, fym;

fym = 'YYYYMM';

date_box_size = 120;

calendar_size = date_box_size * 7 + 14;

module.exports.index = {
  logo: {
    jade: {
      '#logo': 'Getber'
    },
    styl: {
      '#logo': {
        width: 110,
        float: 'left',
        padding: 15,
        fontWeight: '200',
        fontSize: 15,
        color: 'white',
        textAlign: 'right'
      }
    }
  },
  layout: {
    jade: {
      '+navbar': '',
      '#wrapper': {
        '+sidebar': '',
        '+yield': ''
      }
    },
    styl: {
      body: {
        backgroundColor: '#ddd'
      }
    },
    navbar: {
      sidebar: true,
      login: true,
      menu: 'home map calendar vehicle request log help'
    }
  },
  home: {
    label: 'Home',
    sidebar: 'sidebar_home',
    router: {
      path: '/'
    },
    jade: {
      '#contentWrapper': {
        'h2#title': 'Sign up with UBER',
        '.col-md-6#e1': {
          'p#name': 'Isaac Han',
          'p#address': '2353 Hagen Link NW, Edmonton, AB T6R 0B2',
          br: '',
          'with uber': {
            '+button': ''
          }
        },
        '.col-md-6#e2': {
          '': 'a(class="btn-info", href="<%= @oauth %>") Connect with Uber'
        },
        '.col-md-6#e3': 'S {{hello}}',
        '#items': {
          '.col-md-11#pack': {
            'each items': {
              '+item': ''
            }
          }
        }
      }
    },
    eco: function() {
      return {
        oauth: function() {
          return Settings["private"].uber_oauth_url + "?" + x.queryString(Settings["private"].uber_oauth);
        }
      };
    },
    methods: {
      hello: function(name) {
        return 'Hello ' + name + '!';
      }
    },
    helpers: {
      items: function() {
        return db.Items.find({}, {
          sort: {
            created_time: -1
          }
        });
      },
      uber: function() {
        return {
          "class": 'btn-success',
          id: 'uber-botton',
          label: 'Connect with Uber'
        };
      },
      hello: function() {
        return Session.get('hello2');
      }
    },
    events: {
      'click #uber-botton': function(event) {
        return console.log('uber');
      }
    },
    styl: {
      '#items .item': {
        backgroundColor: 'white',
        width: 240,
        height: 240,
        float: 'left',
        margin: 6
      },
      '#title': {
        width: 500
      },
      '#name': {
        width: 200
      },
      '#address': {
        width: 400
      }
    },
    onCreated: function() {
      return Meteor.call('hello', 'world', function(e, result) {
        return Session.set('hello2', result);
      });
    },
    onRendered: function() {
      x.timeout(40, function() {
        return $('#pack').masonry({
          itemSelector: '.item',
          columnWidth: 126
        });
      });
      return ('title name address'.split(' ')).map(function(edit) {
        return $('#' + edit).editable();
      });
    }
  },
  sidebar_home: x.sidebar(['home', 'calendar', 'help']),
  profile: {
    lable: 'Profile',
    sidebar: 'sidebar_profile',
    router: {
      path: 'profile'
    },
    jade: {
      '#contentWrapper': {
        'with user': {
          '| {{name}}': '',
          '| {{phone}}': ''
        }
      }
    },
    helpers: {
      user: function() {
        return {
          name: 'Isaac Han',
          phone: 'xxx-xxxx'
        };
      },
      access_token: function() {
        return 1;
      }
    }
  },
  item: {
    jade: ".item(style='height:{{height}}px;color:{{color}}')"
  },
  submit: {
    label: 'Submit',
    router: {
      path: 'submit'
    },
    jade: {
      h2: 'Connected',
      p: 'access_token is {{token}} {{output}}'
    },
    methods: {
      uber_me: function(token) {
        return HTTP.call('GET', 'https://api.uber.com/v1/me', {
          headers: {
            Authorization: 'Bearer ' + token
          }
        });
      }
    },
    helpers: {
      token: function() {
        return x.hash().access_token;
      },
      output: function() {
        return JSON.stringify(Session.get('uber_me'), null, 4);
      }
    },
    onCreated: function() {
      return Meteor.call('uber_me', x.hash().access_token, function(e, result) {
        return Session.set('uber_me', result);
      });
    }
  },
  vehicle: {
    label: 'Vehicle',
    sidebar: 'sidebar_vehicle',
    router: {
      path: 'vehicle'
    },
    jade: {
      '#contentWrapper': {
        h1: 'You vehicle information',
        br: '',
        '.col-sm-7': {
          'each items': {
            '+form': '',
            br: ''
          }
        }
      }
    },
    helpers: {
      items: function() {
        return [
          {
            label: 'Maker',
            id: 'maker',
            title: 'Car manufacturer',
            icon: 'mobile'
          }, {
            label: 'Model',
            id: 'model',
            title: 'Year of the model',
            icon: 'mobile'
          }, {
            label: 'Color',
            id: 'color',
            title: 'Color of your vehicle',
            icon: 'mobile'
          }
        ];
      }
    },
    events: x.popover('maker model color'.split(' '))
  },
  popover_maker: {
    jade: {
      ul: {
        li: 'manufacturer in 20 characters'
      }
    }
  },
  popover_model: {
    jade: {
      ul: {
        li: 'For digit'
      }
    }
  },
  popover_color: {
    jade: {
      ul: {
        li: 'White or black only'
      }
    }
  },
  sidebar_vehicle: x.sidebar('home map calendar request vehicle log help'.split(' ')),
  map: {
    label: 'Map',
    sidebar: 'sidebar_map',
    router: {
      path: 'map'
    },
    jade: '#map-canvas',
    styl: {
      '#map-canvas': {
        height: '100%',
        padding: 0,
        margin: 0
      }
    },
    onRendered: function() {
      google.maps.event.addDomListener(window, 'load', Pages.map.map_init);
      return x.timeout(10, Pages.map.map_init);
    },
    map_init: function() {
      return new google.maps.Map(document.getElementById('map-canvas'), {
        disableDefaultUI: true,
        zoom: 11,
        center: {
          lat: 53.52,
          lng: -113.5
        }
      });
    }
  },
  sidebar_map: x.sidebar('home map calendar request vehicle log help'.split(' ')),
  calendar: {
    label: 'Calendar',
    router: {},
    jade: {
      '#contentWrapper': {
        '#containerCalendar': {
          '.scrollspy#top': '&nbsp;',
          '#items': '',
          '.scrollspy#bottom': '&nbsp;'
        }
      }
    },
    onRendered: function() {
      var this_month;
      x.calendar(fym, this_month = moment().format(fym));
      $('#top').data({
        id: this_month
      });
      return x.scrollSpy({
        enter: {
          top: function() {
            return x.calendar(moment($('#top').data('id'), fym).subtract(1, 'month').format(fym));
          },
          bottom: function() {
            return x.calendar(moment($('#bottom').data('id'), fym).add(1, 'month').format(fym));
          }
        }
      });
    },
    styl: {
      '#containerCalendar': {
        width: calendar_size,
        maxWidth: calendar_size
      },
      h2: {
        color: 'black',
        display: 'block'
      },
      '.everyday': {
        position: 'relative',
        width: date_box_size,
        height: date_box_size,
        float: 'left',
        padding: 8,
        backgroundColor: 'white',
        margin: 2
      },
      '.month': {
        display: 'block',
        height: calendar_size
      },
      '.spacer': {
        lineHeight: 10
      }
    }
  },
  log: {
    label: 'Log',
    router: {
      path: 'log'
    },
    jade: '#log-canvas',
    onRendered: function() {
      return $('#log-canvas').html('<object id="full-screen" data="http://localhost:8778/"/>');
    },
    styl: {
      '#log-canvas': {
        height: '100%',
        width: '100%'
      },
      '#full-screen': {
        height: '100%',
        width: '100%'
      }
    }
  },
  policy: {
    label: 'Policy',
    router: {
      path: 'policy'
    },
    jade: {
      h2: 'Privacy Policy'
    }
  },
  uber: {
    label: 'uber',
    router: {
      path: 'uber'
    },
    jade: {
      h2: 'Uber'
    }
  },
  redirect: {
    label: 'redirect',
    router: {
      path: 'redirect'
    },
    jade: {
      h2: 'redirect'
    }
  },
  day: {
    collection: 'calendar',
    jade: x.list('init title date day event'),
    helpers: {
      date: function() {
        return moment(this.id, 'YYYYMMDD').format('D');
      },
      day: function() {
        return moment(this.id, 'YYYYMMDD').format('ddd');
      },
      title: function() {
        var _ref;
        return ((_ref = db.Calendar.findOne({
          id: this.id
        })) != null ? _ref['title'] : void 0) || 'Title';
      },
      event: function() {
        return '';
      },
      init: function() {
        x.position({
          parentId: this.id,
          "class": 'title',
          top: 14
        }, x.position({
          parentId: this.id,
          "class": 'event',
          top: 45
        }, x.position({
          parentId: this.id,
          "class": 'date',
          top: 5,
          left: date_box_size - 35
        })));
        x.position({
          parentId: this.id,
          "class": 'day',
          top: 28,
          left: date_box_size - 37
        });
        return '';
      }
    },
    styl: {
      '.init': {
        display: 'none'
      },
      '.title': {
        display: 'inline',
        fontWeight: '100'
      },
      '.date': {
        display: 'inline',
        fontWeight: '600',
        fontSize: '14pt',
        width: 24,
        textAlign: 'right'
      },
      '.day': {
        display: 'table',
        fontWeight: '100',
        float: 'right',
        width: 24,
        textAlign: 'right',
        color: '#444',
        fontSize: '8pt'
      },
      '.event': {
        resize: 'none',
        fontWeight: '100'
      },
      '.row#day01': {
        marginBottom: 0
      }
    }
  },
  gmap: {
    HTML: "<input id=\"pac-input\" class=\"controls\" type=\"text\" placeholder=\"Enter a location\">\n<div id=\"type-selector\" class=\"controls\">\n  <!--input type=\"radio\" name=\"type\" id=\"changetype-all\" checked=\"checked\">\n  <label for=\"changetype-all\">All</label>\n\n  <input type=\"radio\" name=\"type\" id=\"changetype-establishment\">\n  <label for=\"changetype-establishment\">Establishments</label>\n\n  <input type=\"radio\" name=\"type\" id=\"changetype-address\">\n  <label for=\"changetype-address\">Addresses</label>\n\n  <input type=\"radio\" name=\"type\" id=\"changetype-geocode\">\n  <label for=\"changetype-geocode\">Geocodes</label-->\n</div>\n<div id=\"map-canvas\"></div>",
    onRendered: function() {
      google.maps.event.addDomListener(window, 'load');
      return x.timeout(10, x.gmapInit);
    }
  },
  request: {
    label: 'Request',
    router: {
      path: 'request'
    },
    jade: {
      '#contentWrapper': {
        h1: 'Request',
        br: '',
        '.col-sm-9#e11': {
          'each items': {
            '+form': '',
            br: ''
          }
        },
        '.col-sm-9#e12': {
          'input(type="tel",id="mobile-number",class="form-control")': '',
          br: ''
        },
        '.col-sm-9#e13': {
          '+gmap': ''
        }
      }
    },
    styl: {
      '#e13': {
        height: 300
      }
    },
    helpers: {
      items: function() {
        return [
          {
            label: 'Name',
            id: 'name',
            title: 'Your name',
            icon: 'user'
          }, {
            label: 'Phone',
            id: 'phone',
            title: 'Phone Number',
            icon: 'mobile'
          }, {
            label: 'Date',
            id: 'datepicker',
            title: 'Pick your date',
            icon: 'calendar'
          }
        ];
      }
    },
    __helpers: {
      items: function() {
        return ['label, id, title, icon', 'Name    |name    |Your name          |user', 'Phone   |phone   |Phone Number       |mobile', 'Address |address |Your home Zip code |envelope'];
      }
    },
    events: x.popover('name phone address'.split(' ')),
    atRendered: {
      '.ui-datepicker': {
        borderRadius: 0
      },
      '.ui-datepicker-header': {
        backgroundColor: '#eee',
        borderRadius: 0
      },
      '.ui-datepicker-title': {
        fontWeight: ''
      },
      '#ui-datepicker-div': {
        removeClass: '.ui-corner-all'
      },
      '.ui-datepicker-header': {
        removeClass: '.ui-corner-all'
      }
    },
    onRendered: function() {
      $('#datepicker').datepicker();
      return x.timeout(100, function() {
        return $('#mobile-number').intlTelInput({
          preferredCountries: ["ca", "us"],
          utilsScript: "http://jackocnr.com/lib/intl-tel-input/lib/libphonenumber/build/utils.js"
        });
      });
    }
  },
  popover_name: {
    jade: {
      ul: {
        'li Write your name.': '',
        'li No longer then 12 letters.': ''
      }
    }
  },
  popover_phone: {
    jade: {
      ul: {
        li: 'Write your phone number.'
      }
    }
  },
  popover_address: {
    jade: {
      ul: {
        li: 'Write your zipcode.'
      }
    }
  },
  help: {
    label: 'Help',
    router: {},
    jade: {
      '#contentWrapper': {
        h1: 'Help'
      }
    }
  }
};
