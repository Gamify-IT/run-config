#!/usr/bin/env bash
set -e

DEPENDENCIES=(curl docker tar gzip)
WORKDIR="${PWD}/.temp-$(basename "$0")"

DEPLOYMENT_NAME="gamify-it"
DEPLOYMENT_TYPE="DockerCompose"
EXTERNAL_URL="http://localhost"
FILESERVER_KEYCLOAK_CLIENT_SECRET=""
HTTP_PORT=80
HTTPS_PORT=443
KOMPOSE_BINARY_URL="${KOMPOSE_BINARY_URL:-"https://github.com/kubernetes/kompose/releases/download/v1.28.0/kompose-linux-amd64"}"
SERVICES="default keycloak bugfinder chickenshock crosswordpuzzle fileserver finitequiz memory regexgame towercrush"
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

if [[ "$DEPLOYMENT_TYPE" == "Kubernetes" ]]; then
    USER_DEPLOYMENT_NAME="$DEPLOYMENT_NAME"
    USER_EXTERNAL_URL="$EXTERNAL_URL"
    USER_SERVICES="$SERVICES"
    USER_SSL_ENABLED="$SSL_ENABLED"
    USER_VERSION="$VERSION"
    DEPLOYMENT_NAME="gamify-it"
    EXTERNAL_URL="{{ .Values.externalUrl }}"
    SERVICES="{{ .Values.services }}"
    SSL_ENABLED=false
    VERSION="{{ .Values.gamifyItVersion }}"
fi

echo "create docker configuration"
    replaceVariables template/docker/environment > template/docker/.env
    docker compose "${DOCKER_COMPOSE_FILES_ARGUMENTS[@]}" config > docker/docker-compose.yaml

if [[ "$DEPLOYMENT_TYPE" == "DockerCompose" ]]; then
    mv docker/docker-compose.yaml output

    echo "Deployment created. To start it run the following command:"
    echo "    docker compose --file \"${DEPLOYMENT_NAME}-deployment/docker-compose.yaml\" up --detach"


elif [[ "$DEPLOYMENT_TYPE" == "Kubernetes" ]]; then
    echo "create kubernetes configuration"

    curl --silent --location --output kompose "$KOMPOSE_BINARY_URL"
    chmod +x kompose
    ./kompose convert --chart --file docker/docker-compose.yaml --out output --error-on-warning --suppress-warnings
    rm output/README.md output/templates/reverse-proxy-*.yaml \
        output/templates/*-default-networkpolicy.yaml

    # add deployment name as prefix to names
    sed --in-place --expression "s|\(io.kompose.service: \)|\1${DEPLOYMENT_NAME}-|g" \
        --expression "s|\(claimName: \)|\1${DEPLOYMENT_NAME}-|g" \
        --expression "s|^\(  name: \)|\1${DEPLOYMENT_NAME}-|g" \
        --expression "s|^\(              name: \)|\1${DEPLOYMENT_NAME}-|g" \
        --expression "s|^\(        - name: \)|\1${DEPLOYMENT_NAME}-|g" \
        output/templates/*.yaml

    # fix keycloak cannot bind port - change internal port to 8000
    sed --in-place --expression "s|\(          image: ghcr.io/gamify-it/keycloak:{{ .Values.gamifyItVersion }}\)|            - name: KC_HTTP_PORT\n              value: \"8000\"\n\1|" \
        --expression "s|\(- containerPort: \)80|\18000|g" \
        output/templates/keycloak-deployment.yaml
    sed --in-place "s|\(targetPort: \)80|\18000|g" output/templates/keycloak-service.yaml

    for FILE in template/kubernetes/templates/*.yaml; do
        replaceVariables "$FILE" > "output/templates/$(basename "$FILE")"
    done

    DEPLOYMENT_NAME="$USER_DEPLOYMENT_NAME"
    EXTERNAL_URL="$USER_EXTERNAL_URL"
    SERVICES="$USER_SERVICES"
    SSL_ENABLED="$USER_SSL_ENABLED"
    VERSION="$USER_VERSION"
    replaceVariables template/kubernetes/values.yaml > output/values.yaml

    echo "To prevent deleting your persistentVolumes when running \"helm uninstall ${DEPLOYMENT_NAME}\", run the following command:"
    echo 'for PERSISTENT_"VOLUME in $(kubectl get persistentvolume' \
        '--output custom-columns=":.spec.claimRef.name,:.metadata.name"' \
        '| grep gamify-it | sed "s|^.* ||g"); do"'
    echo '    kubectl patch pv "$PERSISTENT_VOLUME" -p {"spec":{"persistentVolumeReclaimPolicy":"Retain"}};'
    echo "done"
    echo
    echo "Please change the \"tlsSecret\" in \"values.yaml\" to your existing secret or" \
        "create a new secret with the following command:"
    echo "    kubectl create secret tls \"${DEPLOYMENT_NAME}\"" \
        "--key \"${SSL_CERTIFICATE_KEY_PATH}\" --cert \"${SSL_CERTIFICATE_PATH}\""
    echo "Deployment created. To start it, run the following commands:"
    echo "    helm install --create-namespace --namespace gamify-it ${DEPLOYMENT_NAME} ${DEPLOYMENT_NAME}-deployment"
else
    echo "Unknown deployment type: \"${DEPLOYMENT_TYPE}\""
    exit 1
fi

mv output ../"${DEPLOYMENT_NAME}-deployment"
rm -f -r "$WORKDIR"

# change to newly created dir and startup the docker container
cd "../gamify-it-deployment"
docker compose up