#!/usr/bin/env bash

git submodule update --init

for i in redis meteor
do
    [[ `parts list` == *"$i"* ]] || parts install $i
done

[ -d ~/node_modules ] || mkdir ~/node_modules
# npm install --prefix ~/node_modules npm
# node npm_packs
> ~/.installed
