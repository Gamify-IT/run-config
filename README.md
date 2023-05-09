# Gamify-IT run-configuration

This repository contains a script for creating a configuration to run the Gamify-IT project.
The script can create a docker configuration or a helm chart for Kubernetes.


## Setup

To create a deployment, download the `create-deployment.sh` script:

```bash
curl --output create-deployment.sh https://github.com/Gamify-IT/run-config/raw/main/create-deployment.sh && \
    chmod +x create-deployment.sh
```

Then you can run it with:

```bash
./create-deployment.sh
```

For information about usage run

```bash
./create-deployment.sh --help
```

Further information about configuring the deployment are available in the [docs](https://gamifyit-docs.readthedocs.io/en/latest/install-manuals/index.html).
