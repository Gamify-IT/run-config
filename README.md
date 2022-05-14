# Gamify-IT-prototype

A github repository containing the **login-backend**, the **overworld** and all **minigames** as **git submodules**.

## How to clone this project

After you cloned the project using `git clone` you need to run these command additionally:

```bash
git submodule init
git submodule update
```

### [Learn more about git submodules](https://www.devroom.io/2020/03/09/the-git-submodule-cheat-sheet/)

## Structure

| service        | port |
| -------------- | ---- |
| login-frontend | 8080 |
| overworld      | 1234 |
| moorhuhn       | 7000 |
| git-card-game  | 7001 |
