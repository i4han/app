#!/usr/bin/env bash

echo "Starting up..."
[ -e ~/.installed ] || ( echo "Install.sh first." && exit 0 )
[ "x"`redis-cli ping` == "xPONG" ] || parts start redis
. profile
cake watch
[ "$(ls -A /tmp)" ] && echo "Not Empty" 