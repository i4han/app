fs = require 'fs-extra'
path = require 'path'
chokidar = require 'chokidar'
{spawn} = require 'child_process'
require 'coffee-script/register'
{Config} = require './config'
package_dir = 'packages'
io = stdio: 'inherit'
isType = (file, type) ->
    path.extname(file) is '.' + type

collect = -> spawn 'collect', [], io
dsync = -> spawn 'dsync', [], io
meteor = -> spawn 'meteor', [], io

compile = ->
    spawn 'coffee', [ '--compile', '--bare', '--output', Config.config_js, Config.config_file], io
        
task_clean = ->
    dsync()
    for file in Config.auto_generated_files
        if fs.existsSync file 
#            console.log file + ' has been deleted.'
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

task 'profile', 'Make shell profile', ->
    home = process.env.HOME
    cwd = process.cwd()
    fs.writeFileSync '../.bashrc', """
        # .bashrc
        # This is created shell script. Edit Cakefile. 
        export PATH="#{home}/node_modules/.bin:#{cwd}:#{cwd}/packages/bin:$PATH"
        export NODE_PATH="#{home}/node_modules:#{Config.config_js}"
        export METEOR_APP=#{cwd}
        export METEOR_LIB=#{cwd}/lib
        export PACKAGES=#{cwd}/packages
        export CDPATH=".:#{home}:#{Config.meteor_dir}:#{Config.package_dir}"
        [[ "x"`~/.parts/bin/redis-cli ping` == "xPONG" ]] || ~/.parts/autoparts/bin/parts start redis

        """, flag: 'w+'

Config.quit()

