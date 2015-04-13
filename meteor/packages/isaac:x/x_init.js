
if ('undefined' === typeof Meteor) {
    module.exports.x = x;
} else if (Meteor) {
	module = {exports: {}};  // module? module={}, module.exports={}
}


x.isEmpty = function(obj) {
    if (obj == null) return true;
    if (obj.length > 0)    return false;
    if (obj.length === 0)  return true;
    for (var key in obj) {
        if (hasOwnProperty.call(obj, key)) return false;
    }
    return true;
}

