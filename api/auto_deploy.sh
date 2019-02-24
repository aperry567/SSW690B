#!/bin/sh

# use a cron tab with
# */10 * * * * /home/ubuntu/SSW690B/api/auto_deploy.sh
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

    ./dod-api-server & echo $! > socket
fi