_.queryString = function ( obj ) {
    var parts = [];
    for ( var i in obj ) {
        if ( obj.hasOwnProperty( i ) ) {
            parts.push( encodeURIComponent( i ) + "=" + encodeURIComponent( obj[ i ] ) );
        }
    }
    return parts.join( "&" );
}

_.addCookie = function ( name, value, expires, path, domain ) {
    var cookie = name + "=" + escape(value) + ";"; 
    if (expires) {
        if ( expires instanceof Date ) {
            if ( isNaN( expires.getTime() ) )
               expires = new Date();
        } else
            expires = new Date(new Date().getTime() + parseInt(expires) * 1000 * 60 * 60 * 24);
        cookie += "expires=" + expires.toGMTString() + ";";
    }
    if (path)
        cookie += "path=" + path + ";";
    if (domain)
        cookie += "domain=" + domain + ";";
    document.cookie = cookie;
}

_.getCookie = function (name) {
    var regexp = new RegExp("(?:^" + name + "|;\s*"+ name + ")=(.*?)(?:;|$)", "g");
    var result = regexp.exec(document.cookie);
    return (result === null) ? null : result[1];
}

_.removeCookie = function (name, path, domain) {
    if (_.getCookie(name))
        _.addCookie(name, "", -1, path, domain);
}