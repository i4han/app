#!/usr/bin/env bash

git submodule update --init

for i in redis meteor
do
    [[ `parts list` =~ $i ]] || parts install $i
done
parts start redis

NODE_MODULES=~/node_modules
[ -d $NODE_MODULES ] || mkdir $NODE_MODULES

for j in coffee-script underscore express stylus fs-extra fibers hiredis redis mongodb chokidar node-serialize request event-stream prompt jade
do
    echo "Installing $j."
    npm install --prefix ~ $j
done

packages/bin/include packages/etc/config.coffee | $NODE_MODULES/.bin/coffee -sc --bare > packages/sat/config.js

if [ ! -e ../.bashrc ]; then
    $NODE_MODULES/.bin/cake profile
    . ~/.bashrc
else
    echo '.bashrc exists. Can not proceed.'
    exit 0
fi

cake config 
cake profile
. ~/.bashrc

for i in client private
do
    [ -d "$i" ] || mkdir "$i"
done

dsync
collect

