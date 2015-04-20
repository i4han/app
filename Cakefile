
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
api     = (require 'absurd')()

{spawn, exec} = require 'child_process'

cwd  = process.cwd()    
home = process.env.HOME
add  = path.join
workspace = 'workspace'
work = add home, workspace
settings_json =  add work, '.settings.json'
settings_cson =  add work, '.settings.cson'
nconf.file file: add work, '.config.json'
Settings = cson.load settings_cson
site     = Settings.site or process.exit(1)
lib_path     = add work, 'lib'
style_path   = add work, 'style'
meteor_path  = add work, 'meteor'
apps_path    = add work, 'apps' 
site_path    = add apps_path, site 
index_coffee = add site_path, 'index.coffee'
site_meteor_path    = add site_path, 'app'    
site_client_path    = add site_meteor_path, 'client'
site_lib_path       = add site_meteor_path, 'lib'
site_public_path    = add site_meteor_path, 'public'
meteor_client_path  = add meteor_path, 'client'
meteor_lib_path     = add meteor_path, 'lib'
meteor_public_path  = add meteor_path, 'public'
meteor_package_path = add meteor_path, 'packages'
x_path    = add meteor_path, 'packages/isaac:x'

{x} = require add x_path, 'x'
x.extend x, (require add x_path, 'x_init').x

theme_cson = add style_path, (Settings[site].theme or Settings.theme) + '.cson'
@Theme = @Module = {}
init_settings = ->
    Settings = cson.load settings_cson
    Ss = Settings[site]
    Ss.public.meteor_methods = []
    x.keys(Ss).map (k) -> x.isObject(Ss[k]) and x.keys(Ss[k]).map (l) ->
        if x.isObject(Ss[k][l])
            method = Ss[k][l].meteor_method
            'string' == typeof method and Ss.public.meteor_methods.push method
    x.extend Settings, Ss
    @Theme = cson.load theme_cson
    @Settings = Settings
init_settings()
lib_files    = x.toArray Settings.lib_files
other_files  = x.toArray Settings.other_files
my_packages  = x.toArray Settings.packages
public_files = x.toArray Settings.public_files
package_paths = my_packages.map (p) -> add meteor_package_path, p
lib_paths     = lib_files  .map (l) -> add lib_path, l + '.coffee'
module_paths  = [index_coffee] 
    .concat lib_files  .map (l) -> add lib_path, l + '.coffee'
    .concat other_files.map (o) -> add site_path, o

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
    fs.writeFile file = add(work, 'install.sh'), data, (err) -> 
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
        fs.writeFile add(home, a[0]), a[1], (err) -> log err or a[1]
    logs.map (a) -> fs.exists f = add( home,'.log.io', a), (ex) -> ex or fs.writeFile f


log = ->
    arguments? and ([].slice.call(arguments)).forEach (str) ->
        fs.appendFile home + '/.log.io/cake', str, (err) -> console.log err if err

isType = (file, type) -> path.extname(file) is '.' + type  # move to x?

collectExt = (dir, ext) ->
    ((fs.readdirSync dir).map (file) -> 
        if isType(file, ext) then fs.readFileSync add dir, file else '').join '\n'

cd     = (dir) -> process.chdir dir

deldir = (dir) ->           # consider async
    return dir if ! dir.match new RegExp "/#{workspace}/"
    if fs.existsSync dir
        (fs.readdirSync dir).forEach (file, index) -> 
            curPath = add dir, file
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
        isType(f, 'coffee') and watched_coffee.push add p, f
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
    chokidar.watch(settings_cson).on 'change', -> settings()
    chokidar.watch(meteor_lib_path).on 'change', (d) -> cp d, add site_lib_path, path.basename d
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
            when 'time'     then console.log new Date()
            when 'publish'  then publish()
            when 'update'   then meteor_update()
            when 'settings' then settings()
            when 'coffee'   then switch line[1] 
                when 'alone' then coffee_alone() 
                when 'clean' then coffee_clean() 
            when 'meteor'   then start_meteor()
            when 'packages' then console.log nconf.get 'updated_packages'; nconf.save()
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


settings = ->
    init_settings()
    (fs.readdirSync apps_path).concat(['private']).map (d) -> delete Settings[d]
    fs.writeFile settings_json, JSON.stringify(Settings, '', 4) + '\n', (e, data) -> 
        console.log new Date(), 'Settings'

mkdir = (dir) -> fs.readdir dir, (e, l) -> e and fs.mkdirSync dir

cpdir = (source, target) ->
    (fs.readdirSync source).map (f) -> f and source and target and cp add(source, f), add target, f

compare_file = (source, target) ->
    true

cp = (source, target) ->
    ! compare_file(source, target) and fs.readFile source, (e, data) -> e or fs.readFile target, (e_t, data_t) ->
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
        package_dir = add meteor_package_path, v
        package_js  = add package_dir, 'package.js'
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
                        cd add meteor_package_path, d
                        meteor_publish()


coffee = (data) -> cs.compile '#!/usr/bin/env node\n' + data, bare:true

directives =
    jade:
        file: '1.jade'
        f: (n, b) -> b = x.indent(b, 1); "template(name='#{n}')\n#{b}\n\n"
    jade$:
        file: '2.html'
        f: (n, b) -> b = x.indent(b, 1); jade.compile( "template(name='#{n}')\n#{b}\n\n", null )()  
    HTML:
        file: '3.html'
        f: (n, b) -> b = x.indent(b, 1); "<template name=\"#{n}\">\n#{b}\n</template>\n"
    head:
        file: '0.jade'
        header: -> 'head\n'    #  'doctype html\n' has not yet suppored
        f: (n, b) -> x.indent(b, 1) + '\n'
    less:
        file: '7.less'
        f: (n, b) -> b + '\n'
    css:
        file: '5.css'
        header: -> collectExt(style_path, 'css') + '\n'
        f: (n, b) -> b + '\n'
    styl:
        file: '4.styl'
        f: (n, b) -> b + '\n\n'
    styl$:
        file: '6.css'
        f: (n, b) -> stylus(b).render() + '\n'

write_build = (file, data) ->
    f = add(site_client_path, file)
    data.length > 0 and fs.readFile f, 'utf8', (err, d) ->
        (!d? or data != d) and fs.writeFile f, data, (e) ->
            fs.writeFile add(meteor_client_path, file), data, (e2) ->
                console.log new Date(), f

toObject = (v) ->
    if !v? then {}
    else if x.isFunction v then (if x.isScalar(r = v.call @) then r else toObject r)
    else if x.isArray  v then v.reduce ((o, w) -> x.extend o, toObject w), {}
    else if x.isObject v then x.keys(v).reduce ((o, k) -> 
        o[k] = if x.isScalar(r = v[k]) then r else toObject r
        o), {}
    else if x.isString v then ((o = {})[v] = '') or o

no_seperator = 'jade jade$'.split ' '

toTidy = (v, n) -> 
    if x.isString v[n] then v[n] 
    else x.tideValue x.tideKey (toObject v[n]), v.block + '-' + v.name, (if n in no_seperator then '' else ' ')

toString = (v, n) -> 
    if x.isString v[n]
        str = v[n]
    else
        v[n] = toObject v[n]
        str = x.indentStyle toTidy v, n
    if x.isEmpty data = toObject v.eco then str
    else eco.render str, toObject data

build = () ->
    console.log new Date()
    init_settings()
    mkdir site_client_path
    @Module = module_paths.reduce ((o, f) -> x.extend o, (v = delete require.cache[f] and require f)[k = x.keys(v)[0]]), {}
    x.keys(@Module).map (name) -> 
        @Module[name].name = name
        @Module[name].block = @Module[name].block or 'x'
    x.keys(directives).map (d) -> 
        write_build (it = directives[d]).file, (x.func(it.header) || '') + 
            x.keys(@Module).map((n) -> (b = toString(@Module[n], d)) and it.f.call @, n, b).filter((o) -> o?).join ''
    x.keys(@Module).map((n, i) -> @Module[n].absurd and api.add toTidy @Module[n], 'absurd')
        .concat([write_build 'absurd.css', api.compile()])
        
    mkdir site_public_path
    fs.readdirSync(meteor_lib_path).map (f) -> 
        cp add(meteor_lib_path,    f), add site_lib_path,    f
    public_files.map (f) -> 
        cp add(meteor_public_path, f), add site_public_path, f

gitpass = ->
    prompt.message = 'github'
    prompt.start()
    prompt.get {name:'password', hidden: true}, (err, result) ->
        fs.writeFileSync add(home, '/.netrc'), """
            machine github.com
                login i4han
                password #{result.password}
            """, flag: 'w+'
        Config.quit(process.exit 1)

task 'watch',     'Start the server',           -> daemon() ; start_up()
task 'clean',     'Remove generated files',     -> coffee_clean()
task 'setup',     'Config and prepare profile', -> profile()  ; logconf()
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

