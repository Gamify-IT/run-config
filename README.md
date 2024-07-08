# Gamify-IT run-configuration

This repository contains a script for creating a configuration to run the Gamify-IT project.
The script can create a docker configuration or a helm chart for Kubernetes.

## Setup
The script will create a docker compose file and start it. Therefore, make sure that docker is running on your machine
**before** executing the script.\
To create a deployment on your local machine, download the `create-deployment.sh` script or clone the repository:

```bash
curl --location --output create-deployment.sh https://github.com/Gamify-IT/run-config/raw/main/create-deployment.sh && \
    chmod +x create-deployment.sh
```

Then open a command line window in the directory of the script and run it (alternatively double-click the file):

```bash
./create-deployment.sh
```

For information about the usage run:

```bash
./create-deployment.sh --help
```

Further information about configuring the deployment are available in the 
[docs](https://gamifyit-docs.readthedocs.io/en/latest/install-manuals/all-services/README.html).


## Test Data
Test data will be included with the run config. If you wish to disable the test data, run the following 
command instead of the one above:
```bash
./create-deployment.sh --test-data
```

### Courses
The test data will create a PSE course with some preconfigured minigames.

### Users
The following users are created with the test data.

| Realm     |   Name   | Password | Description                                                        |
|-----------|:--------:|:--------:|--------------------------------------------------------------------|
| Keycloak  |  admin   |  admin   | Main admin user for Keycloak, can be used to create new users.     |
| Gamify-IT | student  | student  | Test account when logging in as a student.                         |
| Gamify-IT |   max    |   max    | A second student test account for demonstration and test purposes. |
| Gamify-IT | lecturer | lecturer | A lecturer test account for full access on the lecturer interface. |