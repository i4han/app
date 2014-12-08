#!/usr/bin/env bash

git submodule update --init

for i in redis meteor
do
    [[ `parts list` == *"$i"* ]] || parts install $i
done

[ -d ~/node_modules ] || mkdir ~/node_modules
for i in npm # underscore express coffee-script stylus fs-extra fibers hiredis redis mongodb chokidar crypto node-serialize request
do
    npm install --prefix ~/node_modules $i
done
node npm_packs

if [ ! -e profile ]; then
    $HOME/node_modules/.bin/cake profile
    . profile
    cake config profile
fi
. profile

> ~/.installed
