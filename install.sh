#!/usr/bin/env bash

parts install cmake redis meteor
parts start redis
node npm_packages
cake install
cd ../packages/sat
cake all
cd ../../app
meteor update
