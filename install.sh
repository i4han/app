#!/usr/bin/env bash

git submodule update --init

for i in redis meteor
do
    [[ `parts list` =~ $i ]] || parts install $i
done

[ -d ~/node_modules ] || mkdir ~/node_modules

npm install --prefix ~/node_modules npm
node npm_packs

if [ ! -e profile ]; then
    $HOME/node_modules/.bin/cake profile
    . profile
    cake config profile
fi
. profile

[ "x"`redis-cli ping` == "xPONG" ] || parts start redis

> ~/.installed
