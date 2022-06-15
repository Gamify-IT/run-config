# Gamify-IT run-configuration

A github repository containing the **login-backend**, the **overworld** and all **minigames** as images in a docker compose file.

## Structure

| service           | address                      |
| ------------------| -----------------------------|
| login-frontend    | /                            |
| login-backend     | /api/login/                  |
| overworld         | /overworld                   |
| moorhuhn          | /minigames/moorhuhn          |
| git-card-game     | /minigames/git-card-game     |
| crosswordpuzzle   | /minigames/crosswordpuzzle/  |

## User manual

Run the docker containers with the following command:
```sh
docker-compose up -d
```
Now you can access them at [http://localhost:80](http://localhost:80).  
To access them externally replace localhost with your IP.  

To monitor the containers you can use the following command:
```sh
docker-compose ps -a
```
To stop the containers you can use the following command:
```sh
docker-compose stop
```
To stop and remove the containers you can use the following command:
```sh
docker-compose down
```
