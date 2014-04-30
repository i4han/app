fs = require 'fs-extra'
path = require 'path'
chokidar = require 'chokidar'
{spawn} = require 'child_process'
require 'coffee-script/register'
{Config} = require './lib/config'
clone = require("nodegit").Repo.clone;

isType = (file, type) ->
    path.extname(file) is '.' + type

collect = ->
    spawn 'collect', [], stdio: 'inherit'  

git_clone = (dir, url) ->
    clone url, dir, null, (err, repo) -> throw err if err

task 'watch', 'start the server', ->
    watcher = chokidar.watch Config.source_dir, persistent:true
    watcher.on 'add', (file) ->
        collect() if isType file, 'coffee'
    watcher.on 'change', (file) ->
        collect() if isType file, 'coffee'
    
task 'clean', 'remove generated files', ->
    for file in Config.auto_generated_files
        console.log( file + ' has been deleted.' )
        fs.unlinkSync file if fs.existsSync file
    collect()

task 'install', 'install packages', ->
    process.chdir '..'
    package_dir = 'packages'
    if ( ! fs.existsSync(package_dir) )
        fs.mkdirSync(package_dir);
    process.chdir(package_dir);
    git_clone 'sat', 'https://github.com/i4han/sat.git'
