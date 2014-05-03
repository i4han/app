#!/usr/bin/env bash

parts install redis meteor
parts start redis
node npm_packs
BIN="$HOME/node_modules/.bin"
$BIN/cake install
$BIN/cake config
$BIN/cake profile
. profile
cake profile
. profile
cd sat
cake all
cd ~/workspace
meteor update
cake reset
cake watch
