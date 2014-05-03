#!/usr/bin/env bash

cd
parts install redis meteor
parts start redis
if [ ! -d "~/node_modules" ]; then
    mkdir ~/node_modules
fi
npm install --prefix ~/node_modules npm
node npm_packs
BIN="$HOME/node_modules/.bin"
$BIN/cake install
$BIN/cake profile
. profile
cake config
cake profile
cat profile
. profile
cd sat
cake all
cd ~/workspace
meteor update
if [ ! -d "client" ]; then
    mkdir client
fi
cake reset
cake watch

