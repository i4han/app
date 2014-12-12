var dns = require('dns');    
var exec = require('child_process').exec;

exec('ls', function (err, stdout, stderr){});

exec('curl ifconfig.me', function (err, stdout, stderr) {
    console.log('stdout:' + stdout);
    var addr = '' + stdout
    dns.reverse('54.224.72.30', function(err, domain) {
        console.log( domain );
    });
});
