#!/usr/bin/env bash

git submodule update --init

for i in redis meteor
do
    [[ `parts list` =~ $i ]] || parts install $i
done

parts start redis

[ -d ~/node_modules ] || mkdir ~/node_modules

for j in coffee-script underscore express stylus fs-extra fibers hiredis redis mongodb chokidar node-serialize request event-stream
do
    echo "Installing $j."
    npm install --prefix ~ $j
done

packages/bin/include packages/etc/config.source > packages/etc/config.coffee

if [ ! -e ../.bashrc ]; then
    $HOME/node_modules/.bin/cake profile
    . ~/.bashrc
    cake config 
    cake profile
else
    echo '.bashrc exists. Can not proceed.'
    exit 0
fi
. ~/.bashrc
include packages/etc/config.source > packages/etc/config.coffee


for i in client lib private
do
    [ -d "$i" ] || mkdir "$i"
done
[ "$(ls -A lib)" ] || dsync
collect

> ~/.installed
