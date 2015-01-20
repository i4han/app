#!/usr/bin/env bash

for i in meteor mongodb
do
    [[ `parts list` =~ $i ]] || parts install $i
done

NODE_MODULES=~/node_modules
[ -d $NODE_MODULES ] || mkdir $NODE_MODULES

# hiredis redis
for j in coffee-script underscore express stylus fs-extra fibers mongodb chokidar node-serialize request event-stream prompt jade ps-node MD5 googleapis
do
    echo "Installing $j."
    npm install --prefix ~ $j
done

for k in rmate
do
    gem install $k
done

[ -d ~/data ] || mkdir ~/data
mongod --port 7017 --dbpath ~/data <<EOF # port should be 27017 but codio opens only 4999~9999
use meteor
EOF

$NODE_MODULES/.bin/coffee -c --bare lib/config.coffee > app/packages/sat/config.js

if [ ! -e ../.bashrc ]; then
    $NODE_MODULES/.bin/cake profile
    . ~/.bashrc
else
    echo '.bashrc exists. Can not proceed.'
    exit 0
fi

cake setup
. ~/.bashrc
cd app
meteor update
