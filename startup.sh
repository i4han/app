#!/usr/bin/env bash

echo "Starting up..."
[ -e ~/.installed ] || ( echo "Install.sh first." && exit 0 )
[ "x"`redis-cli ping` == "xPONG" ] || parts start redis
cake watch