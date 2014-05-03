#!/usr/bin/env bash

cd ~/workspace
. profile
git add --all
git commit -m $1
cd
cd bin
git add --all
git commit -m $1
cd
cd sat
git add --all
git commit -m $1
git push 
cd bin
git push
cd ~/workspace
git push