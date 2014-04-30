#!/usr/bin/env node
/*
 * Date: 2014-04-30
 * Time: 12:41 AM
 */

var npm = require('npm');
var spawn = require('child_process').spawn
var home = process.env.HOME


var extra = 'bitcore ddp'
var packages = 'nodegit stylus express coffee-script jade fibers hiredis redis markdown mongodb redis underscore chokidar crypto fs-extra moment node-serialize request' .split(' '); 
process.chdir(home);
npm.load({}, function (err) {
  if (err) throw (err);
  packages.map( function(package) {
      npm.commands.install([package], function (err, data) { if (err) throw (err); });
  });
  npm.on("log", function (message) { console.log(message) })
})

