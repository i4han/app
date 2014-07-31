#!/usr/bin/env bash

#git submodule update --init
git submodule foreach git pull origin master
parts install redis meteor
parts start redis
if [ ! -d "~/node_modules" ]; then
    mkdir ~/node_modules
fi
npm install --prefix ~/node_modules npm
node npm_packs
$HOME/node_modules/.bin/cake profile
. profile
cake config profile #
. profile
if [ ! -d "client" ]; then
    mkdir client
fi
collect
# meteor update
cake watch