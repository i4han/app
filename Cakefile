main = 'startup'
  
fs = require 'fs'
path = require 'path'
chokidar = require 'chokidar'
try
    {Config} = require './packages/sat/config'
catch e
    console.log 'Temporary Config used.'
    Config = 
        config_source: 'packages/etc/config.coffee'
        config_js:     'packages/sat/config.js'
        config_js_dir: '/home/codie/sat'
        meteor_dir:    '/home/codio/workspace'
        package_dir:   '/home/codio/workspace/packages'
        auto_generated_files: 'auto_'
        quit: -> {}
        
{spawn, exec} = require 'child_process'
redis = (func) ->
    exec 'parts start redis', (err, stdout, stderr) ->
        func() if func


io = stdio: 'inherit'
isType = (file, type) ->
    path.extname(file) is '.' + type

collect = -> spawn 'collect', [], io
dsync = -> spawn 'dsync', [], io
meteor = -> spawn 'meteor', [], io

deldir = (path) ->
    if fs.existsSync path
        ( fs.readdirSync path ).forEach (file, index) -> 
            curPath = path + '/' + file
            fs.unlinkSync curPath unless (fs.lstatSync curPath).isDirectory()
                

configure = (func) ->
    redis ->
        exec 'include ' + Config.config_source + ' | coffee -sc --bare > ' + Config.config_js, (err, stdout, stderr) -> 
            func() if func
            console.log err if err

reset = ->
    clean_up()
    dsync()
    collect()
    
            
clean_up = ->
    deldir process.env.METEOR_LIB 
    for file in Config.auto_generated_files
        fs.unlinkSync file if fs.existsSync file

start_up = ->
    conf = chokidar.watch Config.config_source, persistent:true
    conf.on 'change', (file) -> compile()
    watcher = chokidar.watch Config.source_dir, persistent:true
    watcher.on 'add', (file) ->
        collect() if isType file, 'coffee'
    watcher.on 'change', (file) ->
        collect() if isType file, 'coffee'
    meteor()

        
task 'start', 'Start the server', ->
    redis start_up

task 'config', 'Compile config file.', -> configure null
task 'clean', 'Remove generated files', -> clean_up()
task 'reset', 'Reset files', -> configure reset     
task 'redis', 'Start redis', -> redis null
task 'profile', 'Make shell profile', ->
    home = process.env.HOME
    cwd = process.cwd()
    fs.writeFileSync '../.bashrc', """
        # .bashrc
        # This is created shell script. Edit Cakefile. 

        export MAIN=#{main}
        export PACKAGES=#{cwd}/packages
        export PATH="#{home}/node_modules/.bin:#{cwd}:$PACKAGES/bin:$PATH"
        export NODE_PATH="#{home}/node_modules:#{Config.config_js_dir}:$PACKAGES/$MAIN"
        export METEOR_APP=#{cwd}
        export METEOR_LIB=#{cwd}/lib
        export CDPATH=".:#{home}:#{Config.meteor_dir}:#{Config.package_dir}"
        [[ "x"`~/.parts/bin/redis-cli ping` == "xPONG" ]] || ~/.parts/autoparts/bin/parts start redis

        """, flag: 'w+'
    
task 'gitpass', 'github.com auto login', ->
    prompt = require 'prompt'
    prompt.message = 'github'
    prompt.start()
    prompt.get {name:'password', hidden: true}, (err, result) ->
        fs.writeFileSync '../.netrc', """
            machine github.com
                login i4han
                password #{result.password}

            """, flag: 'w+'
        Config.quit()
        process.exit(1)
            

Config.quit()

