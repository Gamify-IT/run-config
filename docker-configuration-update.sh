#!/usr/bin/env bash

# update and discard local changes
git fetch
git reset --hard FETCH_HEAD
chmod +x docker-configuration-update.sh

# start new configuration
docker-compose up --remove-orphans -d
docker restart reverse-proxy
docker-compose --file docker-compose-test.yaml up --remove-orphans -d
docker restart reverse-proxy-test
