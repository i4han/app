#!/usr/bin/env bash

cd ~/workspace
cake profile
. profile
git add --all
git commit -m $1
if [ -n "$(git status --porcelain)" ]; then 
  echo "there are changes"; 
else 
  echo "no changes";
fi
git push
cd bin
git add --all
git commit -m $1
git push
cd sat
git add --all
git commit -m $1
git push
