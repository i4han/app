main = 'startup'
{spawn, exec} = require 'child_process'

try
    console.log 'Connecting redis.'
    (require 'redis').createClient().get('a')
catch e
    console.log 'Starting redis.'
    exec 'parts start redis', (err, stdout, stderr) -> {}
    

fs = require 'fs'
path = require 'path'
chokidar = require 'chokidar'
{Config} = require './packages/sat/config'
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
                

compile = ->    
    exec 'include ' + Config.config_source + ' | coffee -sc --bare > ' + Config.config_js, (err, stdout, stderr) -> 
        console.log err if err
#    spawn 'coffee', [ '--compile', '--bare', '--output', Config.config_js, Config.config_file], io
        
task_clean = ->
    deldir process.env.METEOR_LIB 
#    exec 'rm ' + process.env.METEOR_LIB + '/*', (err, stdout, stderr) -> console.log err if err
    for file in Config.auto_generated_files
        if fs.existsSync file 
#            console.log file + ' has been deleted.'
            fs.unlinkSync file
        
task 'watch', 'Start the server', ->
    conf = chokidar.watch Config.config_source, persistent:true
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
    dsync()
    collect()
    
task 'redis', 'Start redis', -> {}

task 'profile', 'Make shell profile', ->
    home = process.env.HOME
    cwd = process.cwd()
    fs.writeFileSync '../.bashrc', """
        # .bashrc
        # This is created shell script. Edit Cakefile. 

        export MAIN=#{main}
        export PATH="#{home}/node_modules/.bin:#{cwd}:#{cwd}/packages/bin:$PATH"
        export NODE_PATH="#{home}/node_modules:#{Config.config_js_dir}"
        export METEOR_APP=#{cwd}
        export METEOR_LIB=#{cwd}/lib
        export PACKAGES=#{cwd}/packages
        export CDPATH=".:#{home}:#{Config.meteor_dir}:#{Config.package_dir}"
        [[ "x"`~/.parts/bin/redis-cli ping` == "xPONG" ]] || ~/.parts/autoparts/bin/parts start redis

        """, flag: 'w+'
    
task 'git', 'github.com auto login', ->
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

