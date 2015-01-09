site = 'site'
  
fs       = require 'fs'
path     = require 'path'
md5      = require 'MD5'
ps       = require 'ps-node'
es       = require 'event-stream'
chokidar = require 'chokidar'

try
    {Config, __} = require './app/packages/sat/config'    
catch e
    {Config, __} = require "./lib/config"

try
    local = require if Config? and Config.local_module? then Config.local_module 
    else './'+ site + '/local.coffee'
catch e
    console.log "local:#{local}:#{e}"
cwd  = process.cwd()    
home = process.env.HOME
    
Config = { 
    index_file:    'index'
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

local ={
    index_file:  'index'
    modules:     'accounts menu ui responsive' .split ' '
    other_files: []
} unless local?

profile = ->
    fs.writeFileSync '../.bashrc', """
        # .bashrc
        # This is created shell script. Edit Cakefile. 

        export WORKSPACE=#{cwd}      # no use
        export SITE=#{cwd}/#{site}   # include
        export BUILD=#{cwd}/#{site}/build
        export MODULE_LIB=#{cwd}/lib
        export METEOR_APP=#{cwd}/app
        export METEOR_LIB=$METEOR_APP/lib
        export PACKAGES=$METEOR_APP/packages
        export PATH="#{home}/node_modules/.bin:#{cwd}/bin:$PATH"
        export NODE_PATH="#{home}/node_modules:#{Config.config_js_dir}:$BUILD"
        export CDPATH=".:#{home}:$METEOR_APP:$SITE"
        [[ "x"`~/.parts/bin/redis-cli ping` == "xPONG" ]] || ~/.parts/autoparts/bin/parts start redis
        export all="Cakefile install.sh lib/* site/*"
        alias red='parts start redis'
        alias sul='rmate -p 8080'
        alias sal='find $all -type f -print0 | xargs -0 -I % rmate -p 8080 % +'
        """, flag: 'w+'

{spawn, exec} = require 'child_process'
redis = (func) ->
    exec 'parts start redis', (err, stdout, stderr) -> func() if func

meteor = ->
    cd Config.meteor_dir
    spawn 'meteor', [], stdio: 'inherit'

isType = (file, type) -> path.extname(file) is '.' + type
cd     = (dir) -> process.chdir dir

deldir = (path) ->           # consider async
    if fs.existsSync path
        ( fs.readdirSync path ).forEach (file, index) -> 
            curPath = path + '/' + file
            fs.unlinkSync curPath unless (fs.lstatSync curPath).isDirectory()
            
clean_up = ->
    deldir Config.sync_dir 
    for file in Config.auto_generated_files
        fs.unlinkSync file if fs.existsSync file

start_up = ->
    sync()  if ! fs.existsSync Config.sync_dir  
    build() if ! fs.existsSync Config.client_dir  # check better than this.
    chokidar.watch Config.build_dir, persistent:true
        .on 'change', (file) -> build() if isType file, 'coffee'
        .on 'add',    (file) -> build() if isType file, 'coffee'
    (local.modules)    .map (file) ->
        chokidar.watch Config.module_dir + file + '.coffee', persistent:true
            .on 'change', (file) -> build()
    ['config_source', 'local_source', 'theme_source'].map (a) ->
        chokidar.watch Config[a], persistent:true
            .on 'change', (file) -> configure()
    [Config.index_module, Config.header_source].concat(local.other_files).map (file) ->
        chokidar.watch Config.site_dir  + file + '.coffee', persistent:true
            .on 'change', (file) -> touch()

    meteor()

mkdir = (path) ->
    if path? then fs.mkdirSync path
    else console.log "path: not defined." 

sync = ->
    sync_dir = Config.sync_dir
    if fs.existsSync sync_dir
        (fs.readdirSync sync_dir).forEach (file) -> 
            fs.unlink sync_dir + file
    else
        mkdir sync_dir

    ([Config.index_module]
        .concat((local.other_files).map (l) -> Config.build_dir  + l )
        .concat((local.modules)    .map (l) -> Config.module_dir + l ))
            .map (l) -> l + '.coffee'
        .forEach (path) ->
#           console.log path + ":" + sync_dir + path.replace /.*?([^\/]*)$/, "$1"
            fs.symlink path, sync_dir + path.replace /.*?([^\/]*)$/, "$1"

readInclude = (path) ->
    ((fs.readFileSync path, 'utf8').split "\n").filter( (a) -> -1 == a.search /#exclude\s*$/ ).join "\n"

include = (data) ->
    if data.search(/^#include\s+local\s*.*/) != -1 then readInclude Config.local_source
    else if data.search(/^#include\s+theme\s*.*/) != -1 then readInclude Config.theme_source
    else data

coffee = (data) -> 
    cs = require 'coffee-script'
    cs.compile '#!/usr/bin/env node' + data, bare:true

configure = () ->
    fs.createReadStream Config.config_source
        .pipe es.split "\n"
        .pipe es.mapSync (data) -> include data
        .pipe es.join "\n"
        .pipe es.wait()
        .pipe es.mapSync (data) -> coffee data
        .pipe fs.createWriteStream Config.config_js

indent = (block, indent) -> 
    if indent then block.replace /^/gm, Array(++indent).join Config.indent_string else block

touch = () ->
    mkdir Config.build_dir
    ([local.index_file].concat(local.other_files)).filter((f) -> f?).map (file) ->
        fs.readFile Config.header_source, 'utf8', (err, head) ->
            fs.createReadStream Config.site_dir + file + '.coffee'
                .pipe es.split "\n"
                .pipe es.mapSync (data) -> indent data, 1
                .pipe es.join "\n"
                .pipe es.wait()
                .pipe es.mapSync (data) -> "#{head}\nmodule.exports.#{file} =\n#{data}"
                .pipe fs.createWriteStream Config.build_dir + file + '.coffee'


build = () ->
    func$str = (what) ->
        @C = Config
        @_ = __
        if !what? then undefined
        else if 'string'   == typeof what then what
        else if 'function' == typeof what then what.call(@, @C, @_)

    mkdir Config.target_dir
    a = [require Config.index_module].concat(
        (local.modules)    .map (module) -> require Config.module_dir + module,
        (local.other_files).map (file)   -> require Config.site_dir   + file )
    (Config.templates).map (kind) ->
        $$ = Config.pages[kind]
        data = ($$.header || '') + ((a     .map (obj) -> 
            (((    Object.keys obj)        .map (module) ->
                (((Object.keys obj[module]).map (page) ->
                    if block = func$str(obj[module][page][kind])
                        #console.log "#{module}:#{page}:#{kind}\n[#{block}]\n" 
                        $$.format.call @, page, indent block, $$.indent 
                ).filter (o) -> o?).join ''
            ).filter (o) -> o?).join ''
        ).filter (o) -> o?).join ''
        fs.readFile $$.file, (err, d) -> if md5(data) != md5 d
            fs.writeFileSync $$.file, data, encoding: 'utf8', flag: 'w+' 

task 'watch',   'Start the server',           -> start_up()
task 'config',  'Compile config file.',       -> configure()
task 'clean',   'Remove generated files',     -> clean_up()
task 'setup',   'Config and prepare profile', -> configure() ; profile()
task 'reset',   'Reset files',                -> configure(); clean_up(); sync(); touch(); build()    
task 'redis',   'Start redis',                -> redis()
task 'profile', 'Make shell profile',         -> profile()
task 'sync',    'Sync source to meteor client files.', -> sync()
task 'touch',   'Compile site files.',        -> touch()
task 'build',   'Build meteor client files.', -> build()
task 'gitpass', 'github.com auto login',  ->
    prompt = require 'prompt'
    prompt.message = 'github'
    prompt.start()
    prompt.get {name:'password', hidden: true}, (err, result) ->
        fs.writeFileSync '../.netrc', """
            machine github.com
                login i4han
                password #{result.password}
            """, flag: 'w+'
        Config.quit(process.exit 1)

Config.quit()

