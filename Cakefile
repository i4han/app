
site = process.env.site or 'apps/getber'
  
fs       = require 'fs'
path     = require 'path'
md5      = require 'MD5'
ps       = require 'ps-node'
es       = require 'event-stream'
chokidar = require 'chokidar'
rm_rf    = require 'rimraf'
{ncp}    = require 'ncp'


cwd  = process.cwd()    
home = process.env.HOME
site = process.env.site
work = home + '/workspace'
site_path = work + '/' + site

try
    {Config, __} = require site_path + '/app/packages/sat/config'    
catch e
    {Config, __} = require work + '/lib/config'

try
    local = require if Config? and Config.local_module? then Config.local_module 
    else work + '/' + site + '/local.coffee'
catch e
    log "local:#{local}:#{e}"
    
Config = { 
    index_file:    'index'
    meteor_dir:     site_path + '/app'
    sync_dir:       site_path + '/app/lib'
    site_packages:  site_path + '/app/packages'
    config_js_dir:  site_path + '/app/packages/sat'
    config_js:      site_path + '/app/packages/sat/config.js'
    packages:       work + '/packages'
    module_dir:     work + '/lib/'
    config_source:  work + '/lib/config.coffee'
    theme_source:   work + '/lib/theme.coffee' 
    site_dir:       work + '/' + site        
    local_source:   work + '/' + site + '/local.coffee'
    auto_generated_files: 'auto_'
    quit: -> {} 
} if !Config? or 0 == Object.keys(Config).length

local = {
    index_file:  'index'
    modules:     'accounts menu ui responsive' .split ' '
    other_files: []
} if !local? or 0 == Object.keys(local).length

logio_port = 8777
rmate_port = 8080
mongo_port = 7017
mongod_option = "-f #{home}/.mongoconf"

mongoconf = ->
    data = """
        systemLog:
            destination: file
            path: "#{home}/.log.io/mongodb"
            logAppend: true
        net:
            bindIp: 127.0.0.1
            port: #{mongo_port}
        storage:
            dbPath: "#{home}/data"
        """
    fs.writeFile file = home + '/.mongoconf', data + '\n', (err) -> log err or data

mongo_str = "mongodb://localhost:#{mongo_port}/meteor"
mongo_str = "mongodb://isaac:1234@ds053858.mongolab.com:53858/meteor"

profile = ->
    data = """
        # .bashrc
        # This is created shell script. Edit Cakefile. 

        export site=#{site}
        export WORKSPACE=#{work}      # no use
        export SITE=#{work}/#{site}   # include
        export BUILD=#{work}/#{site}/build
        export MONGO_URL=#{mongo_str}
        export MODULE_LIB=#{work}/lib
        export METEOR_APP=#{work}/app
        export METEOR_LIB=$METEOR_APP/lib
        export PACKAGES=$METEOR_APP/packages
        export PATH=#{home}/node_modules/.bin:#{work}/bin:$PATH
        export NODE_PATH=#{home}/node_modules:#{Config.config_js_dir}:$BUILD
        export CDPATH=.:#{home}:$METEOR_APP
        export all="#{work}/Cakefile #{work}/install.sh #{work}/lib/header.coffee #{work}/#{site}/*.coffee"
        alias sul='rmate -p #{rmate_port}'
        alias sal='find $all -type f -print0 | xargs -0 -I % rmate -p #{rmate_port} % +'
        alias refresh='. ~/.bashrc'
        alias mngd='mongod #{mongod_option} &'
        alias logs='log.io-server &'
        alias logh='log.io-harvester &'
        alias mng='mongo --port #{mongo_port}'
        #alias red='parts start redis'
        # [[ "x"`~/.parts/bin/redis-cli ping` == "xPONG" ]] || ~/.parts/autoparts/bin/parts start redis
        """
    fs.writeFile home + '/.bashrc', data, (err) -> log err or data

install = ->
    npm_modules = 'coffee-script underscore express stylus fs-extra fibers mongodb chokidar '  + # hiredis redis
              'node-serialize request event-stream prompt jade ps-node MD5 googleapis log.io ' +
              'node-curl node-uber rimraf node-uber browserify '
    data = """
        #!/usr/bin/env bash
        curl -fsSL https://raw.github.com/action-io/autoparts/master/setup.rb | ruby
        
        for i in meteor mongodb
        do [[ `parts list` =~ $i ]] || parts install $i; done
        NODE_MODULES=~/node_modules
        [ -d $NODE_MODULES ] || mkdir $NODE_MODULES
        [ -d ~/data ] || mkdir ~/data
        for j in #{npm_modules}
        do
            echo "Installing $j."
            npm install --prefix ~ $j
        done
        for k in rmate; do gem install $k; done
        $NODE_MODULES/.bin/coffee -c --bare lib/config.coffee > app/packages/sat/config.js
        if [ ! -e ../.bashrc ]; then
            $NODE_MODULES/.bin/cake profile
            . ~/.bashrc
        else
            echo '.bashrc exists. Can not proceed.'
            exit 0
        fi
        cake setup
        refresh
        logs
        logh
        cd app
        meteor update
        mongod #{mongod_option}  <<EOF & 
        use meteor
        EOF
        """
    fs.writeFile file = work + '/install.sh', data, (err) -> 
        if err then log err else fs.chmod file, 0o755, (err) -> log err or data

logconf = ->
    logStreams = ((logs = 'meteor mongodb cake satellite'.split ' ').map (a) ->
        "       #{a}: ['#{home}/.log.io/#{a}']").join ',\n'
    host = '0.0.0.0'
    obj  = 
        '.log.io/harvester.conf':"""
            exports.config = {
                nodeName: "app",
                logStreams: {
                    #{logStreams}
                },
                server: {
                    host: '#{host}',
                    port: #{logio_port}
                }
            }
            """
        '.log.io/log_server.conf':"""
            exports.config = {
                host: '#{host}',
                port: #{logio_port}
            }
            """
        '.log.io/web_server.conf':""" 
            exports.config = {
                host: '#{host}',
                port: #{logio_port+1}
            }
            """
    ([k,v] for k,v of obj).forEach (a) ->
        fs.writeFile home + '/' + a[0], a[1], (err) -> log err or a[1]
    logs.map (a) -> fs.exists f = home+'/.log.io/'+a, (ex) -> ex or fs.writeFile f

{spawn, exec} = require 'child_process'

log = ->
    arguments? and ([].slice.call(arguments)).forEach (str) ->
        fs.appendFile home + '/.log.io/cake', str, (err) -> console.log err if err
meteor = ->
    cd Config.meteor_dir
    spawn 'meteor', [], stdio:'inherit'

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

daemon = ->
    ps.lookup command: 'node',   psargs: 'ux', (err, a) -> 
        node_ps = a.map (p) -> (p.arguments?[0].match /\/(log\.io-[a-z]+)$/)?[1]
        'log.io-server'    in node_ps or spawn 'log.io-server',    [], stdio:'inherit'
        'log.io-harvester' in node_ps or setTimeout( ( -> spawn 'log.io-harvester', [], stdio:'inherit' ), 100 )
    ps.lookup command: 'mongod', psargs: 'ux', (err, a) -> 
        a.length or spawn 'mongod', (mongod_option.split ' '), stdio:'inherit'

start_up = ->
    sync()  if ! fs.existsSync Config.sync_dir  
    build() if ! fs.existsSync Config.client_dir  # check better than this.
    
    [Config.index_module, Config.header_source].map (file) ->
        chokidar.watch file + '.coffee', persistent:true
            .on 'change', (file) -> touch()
    local.modules.map (file) ->
        chokidar.watch Config.module_dir + file + '.coffee', persistent:true
            .on 'change', (file) -> build()
    ['config_source', 'local_source', 'theme_source'].map (a) ->
        chokidar.watch Config[a], persistent:true
            .on 'change', (file) -> configure()

    meteor()

mkdir = (path) -> 
    if path? and !fs.existsSync path 
        fs.mkdirSync path

cp = (source, destination) ->
    fs.createReadStream source
        .pipe fs.createWriteStream destination

sync = ->
    log Config.index_module, local.modules
    sync_dir = Config.sync_dir
    if fs.existsSync sync_dir
        (fs.readdirSync sync_dir).forEach (file) -> fs.unlink sync_dir + file
    else
        mkdir sync_dir

    (local.modules.map (l) -> Config.module_dir + l + '.coffee' )
        .concat((fs.readdirSync  Config.build_dir).map (l) -> Config.build_dir  + l )    
        .forEach (path) ->
            filename = path.replace /.*?([^\/]*)$/, "$1"
            fs.createReadStream path
                .pipe es.mapSync (data) ->  c = coffee data ; c
                .pipe fs.createWriteStream sync_dir + filename + '.js'

packages = ->
    target = Config.site_packages
    console.log 'resetting:', target, site, Config.packages
    if target.indexOf(site) > -1
        rm_rf target, (err) -> 
            log err if err
            ncp Config.packages, target, (err) -> 
                log err if err
                configure()
                x = Config.module_dir + 'x.coffee'
                console.log x
                if fs.existsSync x
                    fs.createReadStream x
                        .pipe es.mapSync (data) ->  c = coffee data ; c
                        .pipe fs.createWriteStream Config.site_packages + 'x/x.coffee.js'



readInclude = (path) ->
    ((fs.readFileSync path, 'utf8').split "\n").filter((a)-> -1 == a.search /#exclude\s*$/).join "\n"

include = (data) ->
    if data.search(/^#include\s+local\s*.*/) != -1 then readInclude Config.local_source
    else if data.search(/^#include\s+theme\s*.*/) != -1 then readInclude Config.theme_source
    else data

coffee = (data) -> 
    cs = require 'coffee-script'
    cs.compile '#!/usr/bin/env node' + data, bare:true

configure = () ->
    log Config.config_source
    log Config.local_source
    log Config.theme_source    
    log Config.config_js
    fs.createReadStream Config.config_source
        .pipe es.split "\n"
        .pipe es.mapSync (data) -> include data
        .pipe es.join "\n"
        .pipe es.wait()
        .pipe es.mapSync (data) ->  c = coffee data ; c
        .pipe fs.createWriteStream Config.config_js

indent = (block, indent) -> 
    if indent then block.replace /^/gm, Array(++indent).join Config.indent_string else block

touch = () ->
    log Config.site_dir, Config.build_dir
    mkdir Config.build_dir
    fs.readFile Config.header_source, 'utf8', (err, head) ->
        if err then log err
        else ([local.index_file].concat(local.other_files)).filter((f)->f?).map (file) ->
            fs.readFile Config.site_dir + file + '.coffee', (err, data) ->
                if err 
                    log err 
                else 
                    [head, data].map (a) -> coffee a
                    fs.writeFile Config.build_dir + file + '.coffee', head + data, (err) ->
                        if err then log err else build()

build = () ->
    func$str = (what) ->
        @C = Config
        @_ = __
        @Pages = Pages
        if !what? then undefined
        else if 'string'   == typeof what then what
        else if 'function' == typeof what then what.call(@, @C, @_)

    log Config.index_module, Config.target_dir
    mkdir Config.target_dir
    Pages = ((fs.readdirSync Config.build_dir).map (file) -> 
        require Config.build_dir + file).concat(
        (local.modules)    .map (module) -> require Config.module_dir + module,
        (local.other_files).map (file)   -> require Config.site_dir   + file )
        .reduce(((o,v) -> key = Object.keys(v)[0] ; o[key] = v[key] ; o), {})
    (Config.templates).map (kind) ->
        $$ = Config.pages[kind]
        data = ($$.header || '') + (((Object.keys Pages).map (module) ->
            (((Object.keys Pages[module]).map (page) ->
                if block = func$str(Pages[module][page][kind])
                    $$.format.call @, page, indent block, $$.indent 
                #log "#{module}:#{page}:#{kind}\n[#{block}]\n" 
            ).filter (o) -> o?).join ''
        ).filter (o) -> o?).join ''
        fs.readFile $$.file, (err, d) -> 
            (md5(data) != md5 d) and fs.writeFile $$.file, data, (err) ->
                log if err then err else $$.file

# task 'redis',   'Start redis',                -> redis()
gitpass = ->
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

task 'watch',     'Start the server',           -> daemon() ; start_up()
task 'config',    'Compile config file.',       -> configure()
task 'clean',     'Remove generated files',     -> clean_up()
task 'setup',     'Config and prepare profile', -> configure() ; profile()  ; logconf()
task 'reset',     'Reset files',                -> configure() ; clean_up() ; sync() ; touch() ; build()    
task 'logconf',   'Create log config file',     -> logconf()
task 'mongoconf', 'Create mongo config file',   -> mongoconf()
task 'packages',  'Update packages',            -> packages()
task 'profile',   'Make shell profile',         -> profile()
task 'sync',      'Sync source to meteor client files.', -> sync()
task 'touch',     'Compile site files.',        -> touch() ; build() ; sync()
task 'build',     'Build meteor client files.', -> build()
task 'install',   'Create install.sh',          -> install()
task 'gitpass',   'github.com auto login',      -> gitpass()
task 'daemon',     'start daemons',             -> daemon()

Config.quit()

