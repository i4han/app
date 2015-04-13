
fs       = require 'fs'
path     = require 'path'
md5      = require 'MD5'
ps       = require 'ps-node'
cs       = require 'coffee-script'
es       = require 'event-stream'
eco      = require 'eco'
chokidar = require 'chokidar'
rm_rf    = require 'rimraf'
{ncp}    = require 'ncp'
path     = require 'path'
jade     = require 'jade'
stylus   = require 'stylus'
async    = require 'async'
cson     = require 'CSON'
prompt   = require 'prompt'
nconf    = require 'nconf'

{spawn, exec} = require 'child_process'

indent_str = Array(4 + 1).join ' '
cwd  = process.cwd()    
home = process.env.HOME
workspace     = 'workspace'
work = path.join home, workspace
settings_json =  path.join work, '.settings.json'
settings_cson =  path.join work, '.settings.cson'
nconf.file file: path.join work, '.config.json'
Settings = cson.load settings_cson
site     = Settings.site or process.exit(1)
lib_path     = path.join work, 'lib'
style_path   = path.join work, 'style'
meteor_path  = path.join work, 'meteor'
apps_path    = path.join work, 'apps' 
site_path    = path.join apps_path, site 
index_coffee = path.join site_path, 'index.coffee'
site_meteor_path    = path.join site_path, 'app'    
site_client_path    = path.join site_meteor_path, 'client'
site_lib_path       = path.join site_meteor_path, 'lib'
site_public_path    = path.join site_meteor_path, 'public'
meteor_client_path  = path.join meteor_path, 'client'
meteor_lib_path     = path.join meteor_path, 'lib'
meteor_public_path  = path.join meteor_path, 'public'
meteor_package_path = path.join meteor_path, 'packages'
x_path    = path.join meteor_path, 'packages/isaac:x'

{x} = require path.join x_path, 'x'
x.extend x, (require path.join x_path, 'x_init').x
x.extend Settings, Settings[site]

theme_cson = path.join style_path, Settings.theme + '.cson'
Theme      = cson.load theme_cson
lib_files    = x.toArray Settings.lib_files
other_files  = x.toArray Settings.other_files
my_packages  = x.toArray Settings.packages
public_files = x.toArray Settings.public_files
package_paths = my_packages.map (p) -> path.join meteor_package_path, p
lib_paths     = lib_files  .map (l) -> path.join lib_path, l + '.coffee'

updated = 'updated time'
logio_port = 8777
rmate_port = 8080

###
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
###

mongo_str = "mongodb://isaac:1234@ds053858.mongolab.com:53858/meteor"

profile = ->
    data = """
        export MONGO_URL=#{mongo_str}
        export PATH=#{home}/node_modules/.bin:$PATH  # #{work}/bin:
        export NODE_PATH=#{home}/node_modules        # :#{Config.config_js_dir}:$BUILD
        # alias sal='find $all -type f -print0 | xargs -0 -I % rmate -p #{rmate_port} % +'
        # alias mngd='mongod #{mongod_option} &'
        # alias mng='mongo --port #{mongo_port}'
        alias sul='rmate -p #{rmate_port}'
        alias refresh='. ~/.bashrc'
        alias logs='log.io-server &'
        alias logh='log.io-harvester &'
        """
    fs.writeFile home + '/.bashrc', data, (err) -> log err or data

install = ->
    npm_modules = 'coffee-script underscore express stylus fs-extra fibers mongodb chokidar '  + # hiredis redis
        'node-serialize request event-stream prompt jade ps-node MD5 googleapis log.io ' +
        'node-curl node-uber rimraf eco js2coffee path async readline nconf' #node-uber
    data = """
        #!/usr/bin/env bash
        # curl -fsSL https://raw.github.com/action-io/autoparts/master/setup.rb | ruby
        
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
        
        if [ ! -e ../.bashrc ]; then
            $NODE_MODULES/.bin/cake profile
            . ~/.bashrc
        else
            echo '.bashrc exists. Can not proceed.'
            exit 0
        fi
        cake setup
        refresh
        # logs
        # logh
        """
    fs.writeFile file = path.join(work, 'install.sh'), data, (err) -> 
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
        fs.writeFile path.join(home, a[0]), a[1], (err) -> log err or a[1]
    logs.map (a) -> fs.exists f = path.join( home,'.log.io', a), (ex) -> ex or fs.writeFile f


log = ->
    arguments? and ([].slice.call(arguments)).forEach (str) ->
        fs.appendFile home + '/.log.io/cake', str, (err) -> console.log err if err

isType = (file, type) -> path.extname(file) is '.' + type  # move to x?

collectExt = (dir, ext) ->
    ((fs.readdirSync dir).map (file) -> 
        if isType(file, ext) then fs.readFileSync path.join dir, file else '').join '\n'

cd     = (dir) -> process.chdir dir

deldir = (dir) ->           # consider async
    return dir if ! dir.match new RegExp "/#{workspace}/"
    if fs.existsSync dir
        (fs.readdirSync dir).forEach (file, index) -> 
            curPath = path.join dir, file
            fs.unlinkSync curPath unless (fs.lstatSync curPath).isDirectory()
    dir

clean_up = ->
    deldir site_client_path 
    deldir site_lib_path 

daemon = ->
    ps.lookup command: 'node',   psargs: 'ux', (e, a) -> 
        node_ps = a.map (p) -> (p.arguments?[0]?.match /\/(log\.io-[a-z]+)$/)?[1]
        'log.io-server'    in node_ps or spawn 'log.io-server',    [], stdio:'inherit'
        'log.io-harvester' in node_ps or setTimeout( ( -> spawn 'log.io-harvester', [], stdio:'inherit' ), 100 )

coffee_watch = (o, f) -> spawn 'coffee', ['-o', o, '-wbc', f], stdio:'inherit'
coffee_clean = ->
    ps.lookup command: 'node',   psargs: 'ux', (e, a) -> a.map (p) -> 
        '-wbc' == p.arguments?[3] and process.kill p.pid, 'SIGKILL'

coffee_alone = ->
    coffees = []
    watched_coffee = lib_paths.concat(index_coffee)
    package_paths.map (p) -> (fs.readdirSync p).map (f) -> 
        isType(f, 'coffee') and watched_coffee.push path.join p, f
    ps.lookup command: 'node',   psargs: 'ux', (e, a) -> a.map (p, i) -> 
        if '-wbc' == p.arguments?[3] and (c = p.arguments[4])?
            if (i = watched_coffee.indexOf(c)) <  0 then process.kill p.pid, 'SIGKILL'
            else watched_coffee.splice(i, 1)
        if a.length - 1 == i
            watched_coffee.map (c) -> 
                if c.match /\/packages\// then coffee_watch path.dirname(c), c
                else coffee_watch meteor_lib_path, c

meteor = (dir, port='3000') ->
    cd dir
    spawn 'meteor', ['--port', port, '--settings', settings_json], stdio:'inherit'

meteor_publish = -> spawn 'meteor', ['publish'], stdio:'inherit'


stop_meteor = (func) ->
    ps.lookup psargs: 'ux', (err, a) -> a.map (p, i) ->
        ['3000', '3300'].map (port) -> 
            if '--port' == p.arguments?[1] and port == p.arguments?[2]
                process.kill p.pid, 'SIGKILL'
        a.length - 1 == i and func? and func()

meteor_update = ->
    cd site_meteor_path
    spawn 'meteor', ['update'], stdio:'inherit'

start_meteor = ->
    stop_meteor -> 
        meteor meteor_path, '3300'
        meteor site_meteor_path

hold_watch = (sec) -> updated = process.hrtime()[0] + sec

start_up = ->
    coffee_alone()
    chokidar.watch(settings_cson).on 'change', -> settings() ; reset_settings()
    chokidar.watch(meteor_lib_path).on 'change', (d) -> cp d, path.join site_lib_path, path.basename d
    lib_paths.concat([index_coffee, theme_cson]).map (f) -> chokidar.watch(f).on 'change', -> build()
    hold_watch(2)
    package_paths.map (p) ->
        chokidar.watch(p).on 'change', (f) ->
            if updated < process.hrtime()[0]
                nconf.set 'updated_packages', (((nconf.get 'updated_packages') or [])
                    .concat([dir_f = path.dirname f]).filter((v, i, a) -> a.indexOf(v) == i))
                console.log new Date(), 'Changed', f
    command()

command = ->
    rl = require('readline').createInterface process.stdin, process.stdout
    rl.setPrompt ''
    rl.on('line', (line) ->        
        switch (line = line.replace(/\s{2,}/g,' ').trim().split ' ')[0]
            when '.'        then console.log 'hi'
            when 'build'    then build()
            when 'publish'  then publish()
            when 'update'   then meteor_update()
            when 'coffee'   then switch line[1] 
                when 'alone' then coffee_alone() 
                when 'clean' then coffee_clean() 
            when 'meteor'   then start_meteor()
            when 'packages' then console.log nconf.get 'updated_packages'
            when 'get'      then console.log nconf.get line[1]
            when 'set'      then nconf.set line[1], line[2]
            when 'stop'     then 'meteor' == line[1] and stop_meteor()
            when '' then ''
            else console.log '?'
    ).on 'close', ->
        console.log 'bye!'
        coffee_clean()
        nconf.save()
        process.exit(1)

reset_settings = ->
    Settings = cson.load settings_cson
    x.extend Settings, Settings[site]

settings = ->
    reset_settings()
    (fs.readdirSync apps_path).concat(['private']).map (d) -> delete Settings[d]
    fs.writeFile settings_json, JSON.stringify(Settings, '', 4) + '\n', (e, data) -> 
        console.log new Date(), 'Settings'

mkdir = (dir) -> fs.readdir dir, (e, l) -> e and fs.mkdirSync dir

cpdir = (source, target) ->
    (fs.readdirSync source).map (f) -> f and source and target and cp path.join(source, f), path.join target, f

cp = (source, target) ->
    fs.readFile source, (e, data) -> e or fs.readFile target, (e_t, data_t) ->
        (e_t or data.length > 0 and data.toString() != data_t.toString()) and fs.writeFile target, data, ->
            console.log new Date(), target   
    #(fs.createReadStream source).pipe fs.createWriteStream target

fileStream = (source, target, f) ->
    fs.createReadStream source
        .pipe es.mapSync (data) -> f(data)
        .pipe fs.createWriteStream target

publish = ->
    version = {}
    updated_packages = nconf.get 'updated_packages'
    my_packages.map (v, i) ->
        package_dir = path.join meteor_package_path, v
        package_js  = path.join package_dir, 'package.js'
        isLast = my_packages.length - 1 == i
        (isLast or -1 < updated_packages.indexOf(package_dir)) and fs.readFile package_js, 'utf8', (e, data) ->
            data.match /version:\s*['"]([0-9.]+)['"]\s*,/m
            version[v] = ((RegExp.$1.split '.').map (w, j) -> if j == 2 then String(Number(w) + 1) else w).join '.'
            data = data.replace /(version:\s*['"])[0-9.]+(['"])/m, "$1#{version[v]}$2"
            if ! isLast
                hold_watch(1)
                fs.writeFile package_js, data, 'utf8', (e) -> e and console.log new Date, e
            else 
                async.map x.keys(version), (p) ->
                    data = data.replace((new RegExp("api\.use\\('#{p}.+$", 'm')), "api.use('#{p}@#{version[p]}');")
                hold_watch(1)
                fs.writeFile package_js, data, 'utf8', (e) ->
                    nconf.set 'updated_packages', []
                    nconf.save()
                    e or x.keys(version).concat([my_packages[my_packages.length - 1]])
                    .filter((v, i, a) -> a.indexOf(v) == i).map (d) ->
                        console.log new Date, 'Publishing', d 
                        cd path.join meteor_package_path, d
                        meteor_publish()


coffee = (data) -> cs.compile '#!/usr/bin/env node\n' + data, bare:true

vfunc$str = (obj, pages) ->
    for key, value of obj
        obj[key] = func$str value, undefined, pages
    obj

func$str = (what, obj, pages) ->
    @Settings = Settings
    @Pages = pages
    @Theme = Theme
    obj = if 'function' == typeof obj then vfunc$str obj(), pages else vfunc$str obj, pages
    if !what? then undefined
    else if 'string'   == typeof what then (if x.isEmpty obj then what else eco.render what, obj)
    else if 'object'   == typeof what then (if x.isEmpty obj then x.o what else eco.render (x.o what), obj)
    else if 'function' == typeof what then func$str (what.call @, @C), obj, pages

indent = (block, indent) -> 
    if indent then block.replace /^/gm, Array(++indent).join indent_str else block

directives =
    jade:
        file: '1.jade', indent: 1
        format: (name, block) -> "template(name='#{name}')\n#{block}\n\n"
    jade$:
        file: '2.html', indent: 1
        format: (name, block) -> jade.compile( "template(name='#{name}')\n#{block}\n\n", null )()  
    HTML:
        file: '3.html', indent: 1
        format: (name, block) -> "<template name=\"#{name}\">\n#{block}\n</template>\n"
    head:
        file: '0.jade', indent: 1
        header: -> 'head\n'    #  'doctype html\n' has not yet suppored
        format: (name, block) -> block + '\n'
    less:
        file: '7.less', indent: 0
        format: (name, block) -> block + '\n'
    css:
        file: '5.css',  indent: 0
        header: -> (collectExt style_path, 'css') + '\n'
        format: (name, block) -> block + '\n'
    styl:
        file: '4.styl', indent: 0
        format: (name, block) -> block + '\n\n'
    styl$:
        file: '6.css',  indent: 0
        format: (name, block) -> stylus(block).render() + '\n'

build = () ->
    log index_coffee, site_client_path
    mkdir site_client_path
    Pages = [index_coffee]
        .concat lib_files  .map (l) -> path.join lib_path, l + '.coffee'
        .concat other_files.map (o) -> path.join site_path, o
        .map (f) -> delete require.cache[f] ; require f
        .reduce ((o,v) -> x.keys(v[k = x.keys(v)[0]]).map((l) -> o[l] = v[k][l]) ; o), {}
    x.keys(directives).map ($) ->
        it = directives[$]
        data = (x.func(it.header) || '') + (((x.keys Pages).map (name) ->
            if (block = func$str Pages[name][$], Pages[name].eco, Pages)
                it.format.call @, name, indent block, it.indent 
        ).filter (o) -> o?).join ''
        file = path.join site_client_path, it.file
        data.length > 0 and fs.readFile file, 'utf8', (err, d) ->
            (!d? or data != d) and fs.writeFile file, data, (e) ->
                fs.writeFile path.join(meteor_client_path, it.file), data, (e2) ->
                    console.log new Date(), file
    mkdir site_public_path
    public_files.map (f) -> cp path.join(meteor_public_path, f), path.join site_public_path, f

gitpass = ->
    prompt.message = 'github'
    prompt.start()
    prompt.get {name:'password', hidden: true}, (err, result) ->
        fs.writeFileSync path.join(home, '/.netrc'), """
            machine github.com
                login i4han
                password #{result.password}
            """, flag: 'w+'
        Config.quit(process.exit 1)

task 'watch',     'Start the server',           -> daemon() ; start_up()
task 'clean',     'Remove generated files',     -> coffee_clean()
task 'setup',     'Config and prepare profile', -> profile()  ; logconf()
task 'reset',     'Reset files',                -> clean_up() ; sync() ; touch() ; build()    
task 'logconf',   'Create log config file',     -> logconf()
task 'mongoconf', 'Create mongo config file',   -> mongoconf()
task 'publish',   'Publish Meteor packages',    -> publish()
task 'profile',   'Make shell profile',         -> profile()
task 'build',     'Build meteor client files.', -> build()
task 'install',   'Create install.sh',          -> install()
task 'gitpass',   'github.com auto login',      -> gitpass()
task 'daemon',    'start daemons',              -> daemon()
task 'settings',  'Settings',                   -> settings()
task 'meteor',    'Start meteor',               -> start_meteor()

