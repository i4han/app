#!/usr/bin/env bash

echo "Starting up..."
[ -e ~/.installed ] || . install.sh
[ "x"`redis-cli ping` == "xPONG" ] || parts start redis

. profile
cake watch
