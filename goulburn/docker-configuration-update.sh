#!/usr/bin/env bash

# update and discard local changes
git fetch
git reset --hard FETCH_HEAD
chmod +x docker-configuration-update.sh

# start new configuration
docker compose --project-directory prod up -d
docker compose --project-directory test up -d
docker compsoe --project-directory dev up -d
