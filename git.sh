#!/usr/bin/env bash

cd ~/workspace
. profile
git add --all
git commit -m $1
git push
cd bin
git add --all
git commit -m $1
git push
cd sat
git add --all
git commit -m $1
git push
