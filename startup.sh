#!/usr/bin/env bash

[ -f profile ] || ./install.sh

echo "Starting up"
if [ "x"`redis-cli ping` != "xPONG" ]; then
    redis-server &
fi
cake watch
