var dns = require('dns');    
var os = require('os');    
var hostname = os.hostname();   
console.log("Short hostname = ", hostname);     
hostname = 'fresh-private.codio.com'
dns.lookup(hostname, function (err, add, fam) {       
    if (err)    
    {    
             console.log("The error = ", JSON.stringify(err));    
             return;    
    }    
    console.log('addr: ' + add);     
    console.log('family: ' + fam);    
    dns.reverse( add, function(err, domains){    
        if (err) {    
            console.log("The reverse lookup error = ", JSON.stringify(err));    
            return;    
        }    
        console.log("The full domain name ", domains);    
    });    
})