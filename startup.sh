#!/usr/bin/env bash

echo "Starting up..."
[ -e ~/.installed ] || . install.sh
[ "x"`redis-cli ping` == "xPONG" ] || parts start redis

. profile

for i in client lib private
do
    [ -d "$i" ] || mkdir "$i"
done
[ "$(ls -A lib)" ] || homedir home
collect
cake watch
