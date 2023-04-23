#!/usr/bin/env bash
set -e

DEPENDENCIES=()
WORKDIR="${PWD}/.temp-$(basename "$0")"

DEPLOYMENT_NAME="gamify-it"
DEPLOYMENT_TYPE="DockerCompose"
EXTERNAL_URL="http://localhost"
FILESERVER_KEYCLOAK_CLIENT_SECRET=
HTTP_PORT=80
HTTPS_PORT=443
SERVICES=("bugfinder" "chickenshock" "crosswordpuzzle" "default" "fileserver" "finitequiz" "memory" "regexgame" "towercrush")
SSL=true
SSL_CERTIFICATE_PATH="/dev/null"
SSL_CERTIFICATE_KEY_PATH="/dev/null"
VERSION=latest

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Creates a deployment for the Gamify-IT project." 
        echo "ARGUMENT can be"
        echo "    --http-port PORT the http port, default: $HTTP_PORT"
        echo "    --https-port PORT the https port, default: $HTTPS_PORT"
        echo "    --kubernetes create deployment for Kubernetes instead of Docker Compose"
        echo "    --name NAME the name of the deployment. Is used as prefix for container names."
        echo "    --ssl-certificate PATH path of the ssl certificate"
        echo "    --ssl-certificate-key PATH path of the key for the ssl certificate"
        echo "    --ssl-disable disable https, use only http"
        echo "    --test-data add test-data container"
        echo "    --url the external url"
        echo "    --version the version to use, default: latest"
        exit
    fi
done

# check dependencies
for CMD in ${DEPENDENCIES[@]}; do
    if [[ -z "$(which $CMD)" ]]; then
        echo "\"${CMD}\" is missing!"
        exit 1
    fi
done

# check arguments
while [[ -n "$1" ]]; do
    if [[ "$1" == "--http-port" ]]; then
        shift
        HTTP_PORT="$1"
    elif [[ "$1" == "--https-port" ]]; then
        shift
        HTTPS_PORT="$1"
    elif [[ "$1" == "--kubernetes" ]]; then
        DEPLOYMENT_TYPE="Kubernetes"
    elif [[ "$1" == "--name" ]]; then
        shift
        DEPLOYMENT_NAME="$1"
    elif [[ "$1" == "--ssl-certificate" ]]; then
        shift
        SSL_CERTIFICATE_PATH="$1"
    elif [[ "$1" == "--ssl-certificate-key" ]]; then
        shift
        SSL_CERTIFICATE_KEY_PATH="$1"
    elif [[ "$1" == "--ssl-disable" ]]; then
        SSL=false
    elif [[ "$1" == "--test-data" ]]; then
        SERVICES+=("test-data")
    elif [[ "$1" == "--url" ]]; then
        shift
        EXTERNAL_URL="$1"
    else
        echo "Unknown argument: \"$1\""
        exit 1
    fi
    shift
done

if [[ $SSL == true ]]; then
    if [[ -z "$SSL_CERTIFICATE_PATH" ]] || [[ -z "$SSL_CERTIFICATE_KEY_PATH" ]]; then
        echo "ssl-certificate or key is missing"
        exit 1
    fi
    SSL_CERTIFICATE_PATH="$(realpath "$SSL_CERTIFICATE_PATH")"
    SSL_CERTIFICATE_KEY_PATH="$(realpath "$SSL_CERTIFICATE_KEY_PATH")"
fi

if [[ -e "${DEPLOYMENT_NAME}-deployment" ]]; then
    echo "\"${DEPLOYMENT_NAME}-deployment\" already exists. Exit now."
    exit 1
fi

if [[ -e "$WORKDIR" ]]; then
    echo "\"${WORKDIR}\" already exists. Remove in 10 seconds."
    sleep 10
    rm -f -r "$WORKDIR"
fi
mkdir "$WORKDIR"
cp -r docker nginx "$WORKDIR"
cd "$WORKDIR"

replaceVariables(){
    sed --expression "s|###DEPLOYMENT_NAME###|${DEPLOYMENT_NAME}|g" \
        --expression "s|###EXTERNAL_URL###|${EXTERNAL_URL}|g" \
        --expression "s|###FILESERVER_KEYCLOAK_CLIENT_SECRET###|${FILESERVER_KEYCLOAK_CLIENT_SECRET}|g" \
        --expression "s|###HTTP_PORT###|${HTTP_PORT}|g" \
        --expression "s|###HTTPS_PORT###|${HTTPS_PORT}|g" \
        --expression "s|###SSL_CERTIFICATE_PATH###|${SSL_CERTIFICATE_PATH}|g" \
        --expression "s|###SSL_CERTIFICATE_KEY_PATH###|${SSL_CERTIFICATE_KEY_PATH}|g" \
        --expression "s|###VERSION###|${VERSION}|g" \
        "$1"
}

mkdir output

if [[ "$DEPLOYMENT_TYPE" == "DockerCompose" ]]; then
    echo "create nginx configuration"
    replaceVariables nginx/header-main.conf > output/nginx.conf
    if [[ "$SSL" == true ]]; then
        replaceVariables nginx/header-https.conf >> output/nginx.conf
    else
        replaceVariables nginx/header-http.conf >> output/nginx.conf
    fi
    replaceVariables nginx/body.conf >> output/nginx.conf
    replaceVariables nginx/footer.conf >> output/nginx.conf

    echo "create docker configuration"
    replaceVariables docker/environment > docker/.env
    DOCKER_COMPOSE_FILES=()
    for SERVICE in "${SERVICES[@]}"; do
        DOCKER_COMPOSE_FILES+=("--file" "docker/docker-compose-${SERVICE}.yaml")
    done
    docker compose "${DOCKER_COMPOSE_FILES[@]}" config | \
        sed --expression "s|/PATH-TO-NGINX-CONF|.|g" \
        > output/docker-compose.yaml

    echo "Deployment created. To start it run the following command:"
    echo "    docker compose --file \"${DEPLOYMENT_NAME}-deployment/docker-compose.yaml\" up --detach"

elif [[ "$DEPLOYMENT_TYPE" == "Kubernetes" ]]; then
    echo "Not yet implemented"
    #TODO: conversion of compose file with kompose
else
    echo "Unknown deployment type: \"${DEPLOYMENT_TYPE}\""
    exit 1
fi

mv output ../"${DEPLOYMENT_NAME}-deployment"
rm -f -r "$WORKDIR"
