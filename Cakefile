fs = require 'fs-extra'
path = require 'path'
chokidar = require 'chokidar'
{spawn} = require 'child_process'
require 'coffee-script/register'
{Config} = require './lib/config'
clone = require("nodegit").Repo.clone;
package_dir = 'packages'

isType = (file, type) ->
    path.extname(file) is '.' + type

collect = ->
    spawn 'collect', [], stdio: 'inherit'  

meteor = ->
    spawn 'meteor', [], stdio: 'inherit'  

git_clone = (dir, url) ->
    clone url, dir, null, (err, repo) -> throw err if err

rm_rf = (path) ->
    files = [];
    files = fs.readdirSync path
    files.forEach (file, index) ->
        curPath = path + "/" + file
        if fs.lstatSync(curPath).isDirectory()
            rm_rf curPath
        else
            fs.unlinkSync curPath
    fs.rmdirSync path
task_clean = ->
    for file in Config.auto_generated_files
        console.log( file + ' has been deleted.' )
        fs.unlinkSync file if fs.existsSync file    
        
task 'watch', 'Start the server', ->
    watcher = chokidar.watch Config.source_dir, persistent:true
    watcher.on 'add', (file) ->
        collect() if isType file, 'coffee'
    watcher.on 'change', (file) ->
        collect() if isType file, 'coffee'
    meteor()
            
task 'clean', 'Remove generated files', ->
    task_clean()

task 'reset', 'Reset files', ->
    task_clean()
    collect()

task 'install', 'Install packages', ->
    if ! fs.existsSync package_dir
        fs.mkdirSync package_dir
        process.chdir package_dir
        git_clone 'sat', 'https://github.com/i4han/sat.git'

task 'uninstall', 'Uninstall packages', ->
    if fs.existsSync package_dir
        rm_rf package_dir

task 'profile', 'Make shell profile', ->
    home = process.env.HOME
    cwd = process.cwd()
    fs.writeFileSync 'profile', """
        export PATH="#{home}/node_modules/.bin:#{cwd}/packages/bin:$PATH"
        export NODE_PATH="#{home}/node_modules:$NODE_PATH"
        export METEOR_APP=#{cwd}
        """, flag: 'w+'

Config.quit()

