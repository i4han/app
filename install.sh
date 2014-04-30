#!/usr/bin/env bash

parts install cmake redis meteor
parts start redis
node npm_packages
export PATH="$HOME/node_modules/.bin:$PATH"
cake install
cd ../packages/sat
cake all
cd ../../app
meteor update
