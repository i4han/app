#!/usr/bin/env bash

git submodule update --init

for i in redis meteor
do
    [[ `parts list` == *"$i"* ]] || parts install $i
done

[ -d ~/node_modules ] || mkdir ~/node_modules

read -n1 -r -p "Installing npm." key
npm install --prefix ~/node_modules npm
read -n1 -r -p "Installing npm packages." key
node npm_packs

read -n1 -r -p "Creating profile." key
if [ ! -e profile ]; then
    $HOME/node_modules/.bin/cake profile
    . profile
    cake config profile
fi
. profile

[ "x"`redis-cli ping` == "xPONG" ] || parts start redis

> ~/.installed
