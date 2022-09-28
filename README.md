# Gamify-IT run-configuration

A github repository containing a host configuration with the **login**, the **overworld** and all **minigames** as images in a docker compose file.

## Structure

| service           | address                      |
| ------------------| -----------------------------|
| landing-page      | /                            |
| keycloak          | /keycloak                    |
| overworld         | /overworld                   |
| chickenshock      | /minigames/chickenshock      |
| git-card-game     | /minigames/git-card-game     |
| crosswordpuzzle   | /minigames/crosswordpuzzle   |
| regex-game        | /minigames/regex-game        |
| bugfinder         | /minigames/bugfinder         |
| lecturer-interface| /lecturer-interface          |

## Setup

The [`template folder`](./template/) contains a configuration template to host the Gamify-IT project.

A hosting folder contains the following files:
- docker compose file at `docker-compose.yaml`
    - the docker compose configuration which is user to setup all needed containers
- environment variables for the compose file at `.env`
    - some individual environment variables needed for the docker compose file
- nginx configuration at `nginx/conf.d/default.conf`
    - the setup of the reverse proxy which maps the requests to the correct service
- ssl-certs at `ssl-certs/`
    - a folder containing the ssl certifates, not present in the template
- databases at `data/`
    - a folder where all databases are placed, automatically created at startup
- realm-ttemplate for keycloak at `keycloak-realm-template.json`

To run the project by your own beside cloning the template folder a few configuration steps need to be done. The following guides you through all steps. Also make sure you installed [docker](https://docs.docker.com/engine/install/).

### 1. Place the ssl cert

Create a folder called `ssl-certs` and place the ssl-certtificate and the correspondig private key there. An exemplary resulting folder structure looks like this: \
`ssl-certs/my-domain/cert.crt` \
`ssl-certs/my-domain/privatekey.key`

### 2. Adapt the nginx configuration

Open the nginx configuration file places at `nginx/conf.d/default.conf`.

The head of the file looks like this:
```
resolver 127.0.0.11 valid=30s; # Docker nameserver

server {
    listen     80;

    return 301 https://$host$request_uri;
}

server {
    listen     443 ssl;

    ssl_certificate /etc/ssl-certs/my-domain/cert.crt;
    ssl_certificate_key /etc/ssl-certs/my-domain/privatekey.key;
```

Here you need to set the ports for http and https in the listen directive. If you user another port than 443 for https you also have to add the port to the redirect. An example with port 8000 for http and port 8443 for https looks like this:
```
server {
    listen     8000;
    return 301 https://$host:8443$request_uri;
}
server {
    listen     8443 ssl;
```
You also need to adjust the certificate paths to match your certificates.
If you placed your certificate files at `ssl-certs/example.com/cert.crt` at `ssl-certs/example.com/privatekey.key` the resulting lines look like this:
```
ssl_certificate /etc/ssl-certs/example.com/cert.crt;
ssl_certificate_key /etc/ssl-certs/example.com/privatekey.key;
```

### 3. Adjust environment variables for the compose file

In the `.env` file you need to set the url and the ports. For example if you run at `example.com` on 80 for http and 443 for https the resulting file looks like this:
```
url=https://example.com
http_port=80
https_port=443
```
If you run at `example.com` on 8000 for http and 8443 for https the resulting file looks like this:
```
url=https://example.com:8443
http_port=8000
https_port=8443
```

## Run

If you finished the setup you can run the project with the following commands: 

Run the docker containers with the following command:
```sh
docker compose up -d
```
To monitor the containers you can use the following command:
```sh
docker compose ps -a
```
To view the logs you can use the following command:
```sh
docker compose logs
```
To stop the containers you can use the following command:
```sh
docker compose stop
```
To stop and remove the containers you can use the following command:
```sh
docker compose down
```

## Advanced Configuration

### Run services on different hosts

It is possible to run the servcies on different hosts. To run a service on a different host remove it from the `docker-compose.yaml` and add it to a new docker compose file for the other host (for example `docker-compose-host2.yaml`).

To make the services working you need to adjust all linkages to the outsourced service and all linkages of the outsourced service. Therefor you also need to make the services accesable from the other host. This can be achieved by publishing the needed port.
For example if you published the overworld-backend on Port 8080 on host `overworld-host` you change
```
- OVERWORLD_URL=http://overworld-backend/api/v1
```
to
```
- OVERWORLD_URL=http://overworld-host:8080/overworld/api/v1
```
Then you can start the docker-compose files on the corresponding host.