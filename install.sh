#!/usr/bin/env bash
for i in meteor # mongodb
do [[ `parts list` =~ $i ]] || parts install $i; done

NODE_MODULES=~/node_modules
[ -d $NODE_MODULES ] || mkdir $NODE_MODULES
# [ -d ~/data ] || mkdir ~/data   # mongo data

for j in coffee-script underscore express stylus fs-extra fibers mongodb chokidar node-serialize request event-stream prompt jade ps-node MD5 googleapis log.io rimraf # hiredis redis
do
    echo "Installing $j."
    npm install --prefix ~ $j
done

# for k in rmate; do gem install $k; done # sublime ssh tunnuling

$NODE_MODULES/.bin/coffee -c --bare lib/config.coffee > app/packages/sat/config.js
if [ ! -e ../.bashrc ]; then
    $NODE_MODULES/.bin/cake profile
    . ~/.bashrc
else
    echo '.bashrc exists. Can not proceed.'
    exit 0
fi
cake setup
refresh
cd app
meteor update
# mongod --port 7017 --dbpath ~/data --logpath /home/codio/.log.io/mongodb <<EOF & 
use meteor
EOF