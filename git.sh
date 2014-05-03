#!/usr/bin/env bash

gitup() {
    git add --all
    if [ -n "$(git status --porcelain)" ]; then 
        git commit -m $1
        git push
    else 
        echo "No changes.";
    fi
}

cd ~/workspace
cake profile
. profile
gitup $1

for i in bin browser sat
do
    echo
    cd $i
    gitup $1
done
