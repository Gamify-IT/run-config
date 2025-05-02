#!/usr/bin/env bash
set -e

DEPENDENCIES=(curl docker tar gzip)
WORKDIR="${PWD}/.temp-$(basename "$0")"

DEPLOYMENT_NAME="gamify-it"
EXTERNAL_URL="http://localhost"
FILESERVER_KEYCLOAK_CLIENT_SECRET=""
HTTP_PORT=80
HTTPS_PORT=443
SERVICES="default keycloak bugfinder chickenshock crosswordpuzzle fileserver finitequiz memory regexgame towercrush towerdefense"
SSL_CERTIFICATE_PATH="/dev/null"
SSL_CERTIFICATE_KEY_PATH="/dev/null"
SSL_ENABLED=true
TEST_DATA=true
PACKAGE_URL="https://api.github.com/repos/Gamify-IT/run-config/tarball/main"
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
        echo "    --name NAME the name of the deployment. Is used as prefix for container names"
        echo "    --services SERVICES specify services to deploy, default: \"${SERVICES}\""
        echo "    --ssl-certificate PATH path of the ssl certificate"
        echo "    --ssl-certificate-key PATH path of the key for the ssl certificate"
        echo "    --ssl-disable disable https, use only http"
        echo "    --test-data remove test-data container"
        echo "    --url the base URL where Gamify-IT will be accessible on. Use protocol prefix and no trailing slashes, i.e. https://www.example.com"
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
        SSL_ENABLED=false
    elif [[ "$1" == "--test-data" ]]; then
        TEST_DATA=false
    elif [[ "$1" == "--url" ]]; then
        shift
        EXTERNAL_URL="$1"
    elif [[ "$1" == "--version" ]]; then
        shift
        VERSION="$1"
    else
        echo "Unknown argument: \"$1\""
        exit 1
    fi
    shift
done

if [[ "$SSL_ENABLED" == true ]]; then
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
    echo "\"${WORKDIR}\" exists already. Removing in 10 seconds. Cancel this command to prevent data loss"
    sleep 10
    rm -f -r "$WORKDIR"
fi

mkdir "$WORKDIR"
cd "$WORKDIR"
mkdir docker output template
curl --silent --location "$PACKAGE_URL" | \
    tar --directory template --extract --gzip --strip-components 2 --wildcards '*/template'

replaceVariables(){
    sed --expression "s|###DEPLOYMENT_NAME###|${DEPLOYMENT_NAME}|g" \
        --expression "s|###EXTERNAL_URL###|${EXTERNAL_URL}|g" \
        --expression "s|###FILESERVER_KEYCLOAK_CLIENT_SECRET###|${FILESERVER_KEYCLOAK_CLIENT_SECRET}|g" \
        --expression "s|###HTTP_PORT###|${HTTP_PORT}|g" \
        --expression "s|###HTTPS_PORT###|${HTTPS_PORT}|g" \
        --expression "s|###SERVICES###|${SERVICES}|g" \
        --expression "s|###SSL_CERTIFICATE_PATH###|${SSL_CERTIFICATE_PATH}|g" \
        --expression "s|###SSL_CERTIFICATE_KEY_PATH###|${SSL_CERTIFICATE_KEY_PATH}|g" \
        --expression "s|###SSL_ENABLED###|${SSL_ENABLED}|g" \
        --expression "s|###VERSION###|${VERSION}|g" \
        "$1"
}

DOCKER_COMPOSE_FILES_ARGUMENTS=()
for SERVICE in $SERVICES; do
    DOCKER_COMPOSE_FILES_ARGUMENTS+=("--file" "template/docker/docker-compose-${SERVICE}.yaml")
done
if [[ "$TEST_DATA" == true ]]; then
    DOCKER_COMPOSE_FILES_ARGUMENTS+=("--file" "template/docker/docker-compose-test-data.yaml")
fi

echo "create docker configuration"
    replaceVariables template/docker/environment > template/docker/.env
    docker compose "${DOCKER_COMPOSE_FILES_ARGUMENTS[@]}" config > docker/docker-compose.yaml

    mv docker/docker-compose.yaml output

    echo "Deployment created. To start it run the following command:"
    echo "    docker compose --file \"${DEPLOYMENT_NAME}-deployment/docker-compose.yaml\" up --detach"

mv output ../"${DEPLOYMENT_NAME}-deployment"
rm -f -r "$WORKDIR"

# change to newly created dir and startup the docker container
cd "../gamify-it-deployment"
docker compose up
