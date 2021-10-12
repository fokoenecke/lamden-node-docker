# Lamden Node Docker Image

This project was created to simplify the process of installing and operating a Lamden masternode or delegate. It contains a `Dockerfile` to build a Docker image. In addition, it provides all the information needed to configure the Docker container. This should be all you need for running a node.

The actual project and its documentation can be found here:
- https://lamden.io/
- https://github.com/Lamden/lamden
- https://architecture.lamden.io/nodes/

## Building the image
In the future, already built images will be available in the Docker registry. We recommend using these images. However, it is of course also possible to build your own images.

```bash
docker build -t lamden-node .
```
This command will take several minutes to complete. After that the image should be available under the name `lamden-node:latest`.

Our build uses Lamden's master branch by default and installs the latest version accordingly. To build another version, a special branch or tag can be configured using `LAMDEN_REPO_BRANCH`.
```bash
docker build -t lamden-node:0.01 --build-arg LAMDEN_REPO_BRANCH=0.01 .
```

## Running a node
### Requirements
- Docker https://docs.docker.com/get-docker/
- docker-compose https://docs.docker.com/compose/install/ (optional)

### masternode vs. delegate
There are currently two types of nodes that can be launched from this image: masternodes and deletages. Depending on which node is to be operated, the configuration differs slightly. Namely, masternodes automatically start an additional web service in the container, which also requires configuration. So if a masternode is to be operated, the configuration must be extended by the following environment variable. 

```bash
WEBSERVER_RUN_PARAMS: -k your-key-here!
```

If you operate a delegate, port forwarding `18080:18080` can be omitted, since it is only used for this webserver. Check our docker-compose examples for details.

### Run with docker-compose (recommended)
To start a container with a Lamden node, you need a `docker-compose.yml` in which the necessary configuration environment is defined. To execute the compose-file, you only need the following command.

```bash
docker-compose up -d
```
The following is an shortened version with comments on the important parts.
```yml
version: '3'
services:
  node: # service name
    container_name: lamden-node
    hostname: lamden-node
    image: lamden-node:latest # alternatively use 'build'
    environment:
      LAMDEN_RUN_PARAMS: start -k your-key-here! -c /config/constitution.json masternode # specify the run parameters for your lamden node
    ports:
      - 18080:18080
    volumes:
      - mongodb:/data/db
      - ./test-nodes/config:/config # provide a constitution.json

volumes:
  mongodb:

```

There are three mandatory configuration parameters. Firstly, when the node is started, the type (masternode/delegate) must be specified. In addition, the private key of the wallet must also be specified. Finally, it needs a `constitution.json`, which holds the public keys and IP addresses of the other nodes of the network. For more infomation on these options, check the official documentation.

The first two are determined via a `LAMDEN_RUN_PARAMS`.
```bash
start -k your-key-here! masternode
#or
start -k your-key-here! delegate
```

The constitution file needs to be provided as a volume like this:
```yml
      - ./test-nodes/config:/config # provide a constitution.json
```

### Run with Docker
If you don't want to use docker-compose, the image can also be started via vanilla Docker. Keep in mind that you must have built the image yourself beforehand if you don't use an official one.

```bash
docker run -d -p 18080:18080 --name lamden-node \
-e LAMDEN_RUN_PARAMS="start -k your-key-here! -c /config/constitution.json masternode" \
-v mongodb:/data/db \
-v /absolute/path/to/test-nodes/config:/config \ # absolute path!
lamden-node:latest
```

## Optional Configuration
### cron
The image has the possibility to define cronjobs via environment variables. Just provide the cron definition in environment variables named `CRONTAB_ENTRY_xx` as follows:

```bash
CRONTAB_ENTRY_01: "*/1 * * * * root echo howdy1 > /tmp/cron_test"
CRONTAB_ENTRY_02: "*/2 * * * * root echo howdy2 > /tmp/cron_test"
```

### supervisorctl
The programs running in the image are configured per supervisord. Accordingly, they can be started and stopped from inside and outside the container.

```bash
#inside
supervisorctl start lamden
supervisorctl stop lamden
#outside
docker exec container-name supervisorctl start lamden
docker exec container-name supervisorctl stop lamden
```

### custom contracting repository
Some users build on their own contracting package. To build the image against your own contracting repository, set the following argument during the build.

```yml
# with docker-compose
environment:
      LAMDEN_REPO_BRANCH: https://github.com/Lamden/contracting.git
```
or
```bash
# with docker build
--build-arg LAMDEN_REPO_BRANCH="https://github.com/Lamden/contracting.git"
```