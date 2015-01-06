site = 'site'
  
fs       = require 'fs'
path     = require 'path'
es       = require 'event-stream'
chokidar = require 'chokidar'

try
    {Config} = require './app/packages/sat/config'    
catch e
    {Config} = require "./lib/config"
    
cwd  = process.cwd()    
home = process.env.HOME
    
Config = { 
    meteor_dir:    cwd + '/app'
    sync_dir:      cwd + '/app/lib'
    package_dir:   cwd + '/app/packages'
    config_js_dir: cwd + '/app/packages/sat'
    config_source: cwd + '/lib/config.coffee'
    theme_source:  cwd + '/lib/theme.coffee' 
    local_source:  cwd + '/site/local.coffee'
    config_js:     cwd + '/app/packages/sat/config.js'
    site_dir:      cwd + '/' + site        
    auto_generated_files: 'auto_'
    quit: -> {} 
} unless Config? and Object.keys(Config).length

profile = ->
    fs.writeFileSync '../.bashrc', """
        # .bashrc
        # This is created shell script. Edit Cakefile. 

        export WORKSPACE=#{cwd}      # no use
        export SITE=#{cwd}/#{site}   # include
        export MODULE_LIB=#{cwd}/lib
        export METEOR_APP=#{cwd}/app
        export METEOR_LIB=$METEOR_APP/lib
        export PACKAGES=$METEOR_APP/packages
        export PATH="#{home}/node_modules/.bin:#{cwd}/bin:$PATH"
        export NODE_PATH="#{home}/node_modules:#{Config.config_js_dir}:$SITE"
        export CDPATH=".:#{home}:$METEOR_APP:$SITE"
        [[ "x"`~/.parts/bin/redis-cli ping` == "xPONG" ]] || ~/.parts/autoparts/bin/parts start redis
        alias red='parts start redis'
        alias sul='rmate -p 8080'

        """, flag: 'w+'

{spawn, exec} = require 'child_process'
redis = (func) ->
    exec 'parts start redis', (err, stdout, stderr) -> func() if func


io = stdio: 'inherit'
isType = (file, type) ->
    path.extname(file) is '.' + type

collect = -> spawn 'collect', [], io
# dsync = -> spawn 'dsync', [], io
meteor = ->
    cd Config.meteor_dir
    spawn 'meteor', [], io

cd = (dir) -> process.chdir dir
deldir = (path) ->
    if fs.existsSync path
        ( fs.readdirSync path ).forEach (file, index) -> 
            curPath = path + '/' + file
            fs.unlinkSync curPath unless (fs.lstatSync curPath).isDirectory()
                

__configure = (func) ->
    redis ->
        exec 'include ' + Config.config_source + ' | coffee -sc --bare > ' + Config.config_js, (err, stdout, stderr) ->
            require './app/packages/sat/config'
            func() if func
            console.log err if err

reset = ->
    clean_up()
    sync()
    collect()    
            
clean_up = ->
    deldir Config.sync_dir 
    for file in Config.auto_generated_files
        fs.unlinkSync file if fs.existsSync file

start_up = ->
    ['config_source', 'local_source', 'theme_source'].map (a) ->
        (chokidar.watch Config[a], persistent:true).on 'change', (file) -> configure()
    chokidar.watch Config.source_dir, persistent:true
        .on 'change', (file) -> collect() if isType file, 'coffee'
        .on 'add',    (file) -> collect() if isType file, 'coffee'
    meteor()

sync = ->
    local_config = Config.local_config
    site_dir = Config.site_dir
    sync_dir = Config.sync_dir
    if fs.existsSync sync_dir
        ( fs.readdirSync sync_dir ).forEach (file, index) ->
            fs.unlinkSync path.join( sync_dir, file )
    else
        fs.mkdirSync sync_dir

    if fs.existsSync site_dir
        ( fs.readdirSync site_dir ).forEach (file, index) ->
            if file == local_config
                modules = (require path.join site_dir, local_config ).modules
                modules.forEach (module) ->
                    module_path = path.join Config.module_dir, module + '.coffee'
                    sync_path = path.join sync_dir, module + '.coffee'
                    fs.symlinkSync module_path, sync_path if fs.existsSync module_path
            else        
                fs.symlinkSync( path.join( site_dir, file ), path.join( sync_dir, file ) )

readInclude = (path) ->
    ((fs.readFileSync path, 'utf8').split "\n").filter( (a) -> -1 == a.search /#exclude\s*$/ ).join "\n"

configure = () ->
    coffee = require 'coffee-script'
    fs.createReadStream Config.config_source
        .pipe es.split "\n"
        .pipe es.mapSync (data) ->
            if data.search(/^#include\s+local\s*.*/) != -1 then readInclude Config.local_source
            else if data.search(/^#include\s+theme\s*.*/) != -1 then readInclude Config.theme_source
            else data
        .pipe es.join "\n"
        .pipe es.wait()
        .pipe es.mapSync (data) -> coffee.compile '#!/usr/bin/env node' + data, bare:true
        .pipe fs.createWriteStream Config.config_js

task 'start', 'Start the server', ->
    redis start_up

task 'config', 'Compile config file.', -> configure()
task 'clean', 'Remove generated files', -> clean_up()
task 'reset', 'Reset files', -> configure(); reset()     
task 'redis', 'Start redis', -> redis()
task 'profile', 'Make shell profile', -> profile()
task 'sync', 'Sync source to meteor client files.', -> sync()
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

