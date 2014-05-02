#!/usr/bin/env bash

parts install cmake redis meteor
parts start redis
node npm_packs
DIR="$HOME/node_modules/.bin"
$DIR/cake install
$DIR/cake profile
cd packages/sat
$DIR/cake all
cd ../..
meteor update
. profile
meteor
