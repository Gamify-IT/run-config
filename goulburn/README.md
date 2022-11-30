# Goulburn run-configuration

This folder contains the configuration running on our project internal Server called `Goulburn`.

## deploy containers

To deploy the containers you need to download the certificates from the [secrets repo](https://github.com/Gamify-IT/secrets/tree/main/ssl-certs) and save them in `prod/ssl-certs/`, `test/ssl-certs/` or `dev/ssl-certs/`, depending on the deplozment zou want to use.

Then you need to change zour working directory to the deployment you want to start. For example:
```sh
cd prod
```

Run the docker containers with the following command:
```sh
docker compose up -d
```
Now you can access them at [http://localhost:80](http://localhost:80).  
To access them externally replace localhost with your IP or hostname.  

To monitor the containers you can use the following command:
```sh
docker compose ps -a
```
To stop the containers you can use the following command:
```sh
docker compose stop
```
To stop and remove the containers you can use the following command:
```sh
docker compose down
```

## setup deployment with automatic updates

The containers are updated using watchtower configured in the docker-compose file. To update the docker-compose we use a systemctl timer.

The configuration is written for  a user named `docker-user`. You can create and switch to it with the following lines or use another user and change the configuration.
```bash
sudo adduser docker-user --disabled-password --gecos ""
sudo usermod -aG docker docker-user
sudo su docker-user
```
Then clone the repository into the home directory and switch into it with the following command:
```bash
cd ~/ && git clone https://github.com/Gamify-IT/run-config.git && cd run-config
```
To deploy the container you need to download the certificates from the [secrets repo](https://github.com/Gamify-IT/secrets/tree/main/ssl-certs) and save them in `prod/ssl-certs/`, `test/ssl-certs/` and `dev/ssl-certs/`. \
The remaining commands mostly have to be run by a user with sudo priviledges or a root user. \
To automatically update the docker-compose file we use a systemctl service with correspondig timer:
```bash
chmod +x docker-configuration-update.sh
sudo cp docker-configuration-update.service docker-configuration-update.timer /etc/systemd/system/
sudo systemctl daemon-reload
```
Then we just need to enable the timer and run the service once to start all containers.
```bash
sudo systemctl enable docker-configuration-update.timer
sudo systemctl start docker-configuration-update.timer
sudo systemctl start docker-configuration-update.service
```
Now everything should be up and the configuration is updated daily.