#!/usr/bin/env bash

git submodule update --init
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

for i in client lib private
do
    if [ ! -d "$i" ]; then
        mkdir "$i"
    fi
done

collect
# meteor update
cake watch