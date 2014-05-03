#!/usr/bin/env bash

gitup() {
    git add --all
    if [ -n "$(git status --porcelain)" ]; then 
        git commit -m $1
        git push
    else 
      echo "no changes";
    fi
}

cd ~/workspace
cake profile
. profile
gitup $1
cd bin
gitup $1
cd sat
gitup $1