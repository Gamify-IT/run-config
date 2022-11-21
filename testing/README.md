# Testing run-configuration

This folder contains a configuration for testing purposes on the local machine.

The `docker-compose-latest.yaml` contains containers from the latest releases and `docker-compose-main.yaml` contains containers from the actual main branch.

## start containers

Replace `docker-compose-$STAGE.yaml` with `docker-compose-latest.yaml` or `docker-compose-main.yaml`.

Run the docker containers with the following command:
```sh
docker compose -f docker-compose-$STAGE.yaml up -d
```
Now you can access them at [http://localhost:80](http://localhost:80).  

To monitor the containers you can use the following command:
```sh
docker compose -f docker-compose-$STAGE.yaml ps -a
```
To stop the containers you can use the following command:
```sh
docker compose -f docker-compose-$STAGE.yaml stop
```
To stop and remove the containers you can use the following command:
```sh
docker compose -f docker-compose-$STAGE.yaml down
```

## Test data

This configurations contain test data. For more infformation visit our [test-data repository](https://github.com/Gamify-IT/test-data).