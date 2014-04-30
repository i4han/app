#!/usr/bin/env bash

parts install cmake redis meteor
parts start redis
node npm_packages
DIR="$HOME/node_modules/.bin"
$DIR/cake install
cd ../packages/sat
$DIR/cake all
cd ../../app
meteor update
