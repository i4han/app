#!/usr/bin/env bash

echo "Starting up..."
[ -e ~/.installed ] || ( echo "Install.sh first." && exit 0 )
parts start redis
cake watch