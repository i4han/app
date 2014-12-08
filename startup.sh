#!/usr/bin/env bash

echo "Starting up..."
if [ ! -e profile ]; then
    $HOME/node_modules/.bin/cake profile
    . profile
    cake config profile
fi
. profile

for i in client lib private
do
    [ -d "$i" ] || mkdir "$i"
done
[ "$(ls -A lib)" ] || homedir home
[ "x"`redis-cli ping` == "xPONG" ] || parts start redis
collect
cake watch
