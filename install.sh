#!/usr/bin/env bash

git submodule update --init

for i in redis meteor
do
    [[ `parts list` =~ $i ]] || parts install $i
done

[ -d ~/node_modules ] || mkdir ~/node_modules

for j in coffee-script underscore express stylus fs-extra fibers hiredis redis mongodb chokidar node-serialize request
do
    echo "Installing $j."
    npm install --prefix ~ $j
done

[ "$(ls -A lib)" ] || homedir home
if [ ! -e profile ]; then
    $HOME/node_modules/.bin/cake profile
    . profile
    cake config profile
fi
. profile

[ "x"`redis-cli ping` == "xPONG" ] || parts start redis

for i in client lib private
do
    [ -d "$i" ] || mkdir "$i"
done
[ "$(ls -A lib)" ] || homedir home
collect

> ~/.installed
