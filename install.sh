#!/usr/bin/env bash

git submodule update --init

for i in redis meteor
do
    [[ `parts list` == *"$i"* ]] || parts install $i
done

[ -d ~/node_modules ] || mkdir ~/node_modules
npm install --prefix ~/node_modules npm underscore express coffee-script stylus fibers hiredis redis mongodb chokidar crypto node-serialize request
node npm_packs

if [ ! -e profile ]; then
    $HOME/node_modules/.bin/cake profile
    . profile
    cake config profile
fi
. profile

> ~/.installed
