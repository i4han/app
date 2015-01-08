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
local = require  Config.local_module if Config
    
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

local ={
    modules:     'accounts menu ui responsive' .split ' '
    other_files: []
} unless local?

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
        export all="Cakefile bin/* lib/* site/*"
        export edit="Cakefile bin/save lib/* site/*"
        alias red='parts start redis'
        alias sul='rmate -p 8080'
        alias sal='find $edit -type f -print0 | xargs -0 -I % rmate -p 8080 % +'
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
                
reset = ->
    clean_up()
    sync()
    build()    
            
clean_up = ->
    deldir Config.sync_dir 
    for file in Config.auto_generated_files
        fs.unlinkSync file if fs.existsSync file

start_up = ->
    ['config_source', 'local_source', 'theme_source'].map (a) ->
        (chokidar.watch Config[a], persistent:true).on 'change', (file) -> configure()
#    chokidar.watch Config.source_dir, persistent:true
#        .on 'change', (file) -> build() if isType file, 'coffee'
#        .on 'add',    (file) -> build() if isType file, 'coffee'
    (local.modules)    .map (file) ->
        chokidar.watch Config.module_dir + file + '.coffee', persistent:true
            .on 'change', (file) -> build()
    (local.other_files).map (file) ->
        chokidar.watch Config.site_dir   + file + '.coffee', persistent:true
            .on 'change', (file) -> build()
    chokidar.watch Config.index_module, persistent:true
        .on 'change', (file) -> build()


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

build = () ->
    fs.mkdir Config.target_dir, 0o775, (err) -> err and err.code == 'EEXIST'
    ps.lookup command: 'node', psargs: 'ux', (err, a) -> 
        a.filter( (f) -> if parseInt(f.pid) == process.pid then false else true ).forEach (p) ->
            (process.exit 0 if s.match /\/bin\/save$/) for s in p.arguments

    func$str = (what) ->
        @C = Config
        @_ = __
        if !what? then undefined
        else if 'string'   == typeof what then what
        else if 'function' == typeof what then what.call(@, @C, @_)

    indent = (block, indent) -> 
        if indent then block.replace /^/gm, Array(++indent).join Config.indent_string else block

    a = [require Config.index_module].concat(
        (local.modules)    .map (module) -> require Config.module_dir + module,
        (local.other_files).map (files)  -> require Config.site_dir   + files )
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
        checksum = md5 data
        fs.readFile $$.file, (err, d) ->
            fs.writeFileSync $$.file, data, encoding: 'utf8', flag: 'w+' if checksum != md5 d

task 'start',   'Start the server',       -> start_up()
task 'config',  'Compile config file.',   -> configure()
task 'clean',   'Remove generated files', -> clean_up()
task 'reset',   'Reset files',            -> configure(); reset()     
task 'redis',   'Start redis',            -> redis()
task 'profile', 'Make shell profile',     -> profile()
task 'sync',    'Sync source to meteor client files.', -> sync()
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

