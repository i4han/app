fs = require 'fs'
path = require 'path'
chokidar = require 'chokidar'
{spawn} = require 'child_process'
{Config} = require './lib/config'

DIR = path.join Config.source_dir
 
isType = (file, type) ->
    path.extname(file) is '.' + type

isPrefix = (file, prefix) ->
    file.substring 0, prefix.length is prefix

findFiles = (dir, type, files = {}) ->
    for filename in fs.readdirSync dir
        file = path.join dir, filename
        stats = fs.statSync file
        if stats.isDirectory()
            findFiles file, type, files
        else if isType filename, type
            files[file] = true
    Object.keys files

findPrefixFiles = (dir, prefix, files = {}) ->
    for filename in fs.readdirSync dir
        file = path.join dir, filename
        stats = fs.statSync file
        if stats.isDirectory()
            findPrefixFiles file, prefix, files
        else if isPrefix filename, prefix
            files[file] = true
    Object.keys files

runCollect = (files, cb = ->) ->
    stdio = ['ignore', 'ignore', process.stderr]
    (spawn 'jade', files, {stdio}).on 'exit', cb

libDir = (dir, cb = ->) ->
    runCollect findFiles(dir, 'coffee'), cb

watchDir = (dir) ->
    watcher = chokidar.watch dir

    watcher.on 'add', (file) ->
        runCollect [file] if isType file, 'coffee'

    watcher.on 'change', (file) ->
        runCollect [file] if isType file, 'coffee'


task 'start', 'start the server', ->
    jadeDir DIR, ->
        watchDir DIR
        spawn 'meteor', [], stdio: 'inherit'

task 'collect', 'Collect files', ->
    runCollect

task 'clean', 'remove generated files', ->
    for file in findPrefixFiles Config.target_dir, Config.gen_prefix
        fs.unlinkSync file