#!/usr/bin/env bash

# update and discard local changes
git fetch
git reset --hard FETCH_HEAD

# start new configuration
docker-compose up --remove-orphans -d
