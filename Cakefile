fs = require 'fs-extra'
path = require 'path'
chokidar = require 'chokidar'
{spawn} = require 'child_process'
require 'coffee-script/register'
{Config} = require './config'
clone = require('nodegit').Repo.clone;
package_dir = 'packages'

isType = (file, type) ->
    path.extname(file) is '.' + type

collect = -> spawn 'collect', [], stdio: 'inherit'  
meteor = -> spawn 'meteor', [], stdio: 'inherit'  
git_clone = (dir, url) -> clone url, dir, null, (err, repo) -> throw err if err
compile = ->
    spawn 'coffee', [ '--compile', '--bare', '--output', Config.config_js, Config.config_file], stdio: 'inherit'
        
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
        if fs.existsSync file 
            console.log file + ' has been deleted.'
            fs.unlinkSync file
        
task 'watch', 'Start the server', ->
    conf = chokidar.watch Config.config_file, persistent:true
    conf.on 'change', (file) -> compile()
    watcher = chokidar.watch Config.source_dir, persistent:true
    watcher.on 'add', (file) ->
        collect() if isType file, 'coffee'
    watcher.on 'change', (file) ->
        collect() if isType file, 'coffee'
    meteor()

task 'config', 'Compile config file.', -> compile()
task 'clean', 'Remove generated files', -> task_clean()

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
        export NODE_PATH="#{home}/node_modules:#{Config.config_js}"
        export METEOR_APP=#{cwd}
        """, flag: 'w+'

Config.quit()

