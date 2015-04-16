
x.$.getStyle = function() {
    var dom = this.get(0);
    var style;
    var returns = {};
    if(window.getComputedStyle){
        var camelize = function(a,b){
            return b.toUpperCase();
        };
        style = window.getComputedStyle(dom, null);
        for(var i = 0, l = style.length; i < l; i++){
            var prop = style[i];
            var camel = prop.replace(/\-([a-z])/g, camelize);
            var val = style.getPropertyValue(prop);
            returns[camel] = val;
        };
        return returns;
    };
    if(style = dom.currentStyle){
        for(var prop in style){
            returns[prop] = style[prop];
        };
        return returns;
    };
    return this.css();
};

x.$.copyStyle = function(source) {
  var styles = source.getStyle();
  this.css(styles);
};

x.$.editable = function() {
    var that = this,
        $inputBox = $('<input type="text"></input>').css('min-width', that.width()),
        submitChanges = function() {
            that.html($inputBox.val());
            that.show();
            that.trigger('editsubmit', [that.html()]);
            $(document).unbind('click', submitChanges);
            $inputBox.detach();
        },
        tempVal;
    $inputBox.copyStyle( that );
    $inputBox.css( {'border-bottom':'2px solid black'});
    $inputBox.click(function(event) {
        event.stopPropagation();
    });

    that.dblclick(function(e) {
        tempVal = that.html();
        $inputBox.val(tempVal).insertBefore(that).bind('keypress', function(e) {
            if ($(this).val() !== '') {
                var code = (e.keyCode ? e.keyCode : e.which);
                if (code == 13) {
                    submitChanges();
                }
            }
        });
        that.hide();
        $(document).click(submitChanges);
    });
    return that;    
};

x.gmapInit = function (options) {
  var gmaps = google.maps
  var mapOptions = ! x.isEmpty(options) ? options : {
    disableDefaultUI: true, 
    center: new gmaps.LatLng(53.52, -113.5),
    zoom: 12
  };
  var map = new gmaps.Map(document.getElementById('map-canvas'), mapOptions);

  var input = document.getElementById('pac-input');

  // var types = document.getElementById('type-selector');
  map.controls[gmaps.ControlPosition.TOP_LEFT].push(input);
  // map.controls[gmaps.ControlPosition.TOP_LEFT].push(types);

  var autocomplete = new gmaps.places.Autocomplete(input);
  autocomplete.bindTo('bounds', map);

  var infowindow = new gmaps.InfoWindow();
  var marker = new gmaps.Marker({
    map: map,
    anchorPoint: new gmaps.Point(0, -29)
  });

  gmaps.event.addListener(autocomplete, 'place_changed', function() {
    infowindow.close();
    marker.setVisible(false);
    var place = autocomplete.getPlace();
    if (!place.geometry) {
      return;
    }

    // If the place has a geometry, then present it on a map.
    if (place.geometry.viewport) {
      map.fitBounds(place.geometry.viewport);
    } else {
      map.setCenter(place.geometry.location);
      map.setZoom(16);  // Why 16? Because it looks good.
      map.setMapTypeId('hybrid');
    }
    marker.setIcon(/** @type {gmaps.Icon} */({
      url: place.icon,
      size: new gmaps.Size(71, 71),
      origin: new gmaps.Point(0, 0),
      anchor: new gmaps.Point(17, 34),
      scaledSize: new gmaps.Size(35, 35)
    }));
    marker.setPosition(place.geometry.location);
    marker.setVisible(true);

    var address = '';
    if (place.address_components) {
      address = [
        (place.address_components[0] && place.address_components[0].short_name || ''),
        (place.address_components[1] && place.address_components[1].short_name || ''),
        (place.address_components[2] && place.address_components[2].short_name || '')
      ].join(' ');
    }

    // infowindow.setContent('<div><strong>' + place.name + '</strong><br>' + address);
    // infowindow.open(map, marker);
  });

  // Sets a listener on a radio button to change the filter type on Places
  // Autocomplete.
  /*
  function setupClickListener(id, types) {
    var radioButton = document.getElementById(id);
    gmaps.event.addDomListener(radioButton, 'click', function() {
      autocomplete.setTypes(types);
    });
  }

  setupClickListener('changetype-all', []);
  setupClickListener('changetype-address', ['address']);
  setupClickListener('changetype-establishment', ['establishment']);
  setupClickListener('changetype-geocode', ['geocode']);
  */
}

x.removeRules(Settings.public.remove_rules);



