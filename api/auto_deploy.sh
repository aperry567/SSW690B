#!/bin/sh

# use a cron tab with
# */1 * * * * /home/ubuntu/auto_deploy.sh > /home/ubuntu/cron.log 2>&1
# at the top of the cron tab also put some environment variables to get it working
#SHELL=/bin/bash
#PATH=/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
#GOPATH=/home/ubuntu/.go
#DOD_DB=<db conn string>
#DOD_API_ROOT_DIR=/home/ubuntu/SSW690B/api
cd ~/SSW690B;

git fetch;
LOCAL=$(git rev-parse HEAD);
REMOTE=$(git rev-parse @{u});

#if our local revision id doesn't match the remote, we will need to pull the changes
if [ $LOCAL != $REMOTE ]; then
    #pull and merge changes
    git pull;

    cd ~/SSW690B/api;

    go build -o dod-api-server src/*.go

    kill "$(cat socket)";

    ./dod-api-server & echo $! > socket;
fi
