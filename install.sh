#!/usr/bin/env bash

parts install redis meteor
parts start redis
if [ ! -d "~/node_modules" ]; then
    mkdir ~/node_modules
fi
npm install --prefix ~/node_modules npm
node npm_packs
$HOME/node_modules/.bin/cake install profile
. profile
cake config profile
. profile
cd sat
cake all
if [ ! -d "client" ]; then
    mkdir client
fi
collect
cd workspace
meteor update
cake reset watch