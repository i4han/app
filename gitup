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

if [ $# -eq 0 ]; then
    comment="regular"
else
    comment=$1
fi
cd ~/workspace
cake profile
. profile
gitup $comment
echo

for i in bin browser sat
do
    cd $i
    gitup $comment
    echo
done
