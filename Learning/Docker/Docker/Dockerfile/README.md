# Dockerfile

```
[ Dockerfile ] ---> ( docker build ) ---> [ Docker Image ] ---> ( docker run ) ---> [ Running Container ]
```

- Dockerfile must be exactly called "Dockerfile"
- 4 fundamental instructions: FROM, RUN, COPY, CMD
- Dockerfile is a blueprint for creating docker images
- The first line always in a dockerfile is `FROM image`, we start by basing it on another image, so that image will already be installed inside our image
- Example:
```dockerfile
# install node, we can also specify the version
FROM node:13-alpine
```
- We can look up images on docker hub
- Each docker image on docker hub is also based on its own dockerfile
- Environmental variables inside our image can be set using `ENV`
```dockerfile
# set MONGO_DB_USERNAME=admin
# set MONGO_DB_PWD=password
ENV MONGO_DB_USERNAME=admin \
    MONGO_DB_PWD=password
```
- It is better to write environmental variables in docker compose instead of dockerfile
- Using `RUN` we can execute any kind of Linux commands, INSIDE the container, not on the host
- It creates a new layer on top of the current image
```dockerfile
# create /home/app folder
# this directory is created only inside the container
RUN mkdir -p /home/app
```
- Shell form can be used for various commands (example):
```dockerfile
RUN <<EOF
apt-get update
apt-get install -y curl
EOF
```
- `COPY` command can be used to copy files/directories from the host to the container image
```dockerfile
# copy current folder files to /home/app
COPY ./home/app
```
- `CMD` always takes part of the dockerfile, it executes an entry point Linux command
```dockerfile
CMD ["node", "/home/app/server.js"]
```
- Difference between `RUN` and `CMD`:
```dockerfile
# executes only once, when image is created on disk
RUN apt-get install -y python3
# executes each time the container starts from that image
```

## Building and running an image using Dockerfile
- Using `docker build`
- We specify the image tag/name using the flag `-t` and then write the name as the first argument
- We also need to specify the location of the dockerfile as the second argument
- Whenever we adjust the dockerfile we MUST rebuild the image
- Exmaple:
```bash
docker build -t my-appp:1.0 .
```
- We then run a container using `docker run`
- Example:
```bash
docker run my-app:1.0
```
- We can delete the image using `docker rmi` by specifying the image id
- But we have to stop the current running containers based on the image first by checking them if they are running using `docker ps -a` using `docker rm` and giving the container ID as argument
- `docker stop` safely shuts down a running container; the container still exists in the system's memory, it just isn't actively running
- `docker rm` permanently deletes a stopped container; this wipes out the specific instance and any data inside it that wasn't saved to an external volume
- We can check the logs of a container using `docker logs` and then specifying the container id as the argument
- We can enter the container into its CLI using `docker exec -it` and then specifying the container id and the CLI that we want to use
- Example:
```bash
docker exec -t 51c6912d69f5 /bin/sh
```
- Some containers do not have `bash` installed so `sh` can be used
- We use `exit` to quit the container CLI

## Dockerfile commands overview
| Instruction | Description |
| :--- | :--- |
| **ADD** | Add local or remote files and directories. |
| **ARG** | Use build-time variables. |
| **CMD** | Specify default commands. |
| **COPY** | Copy files and directories. |
| **ENTRYPOINT** | Specify default executable. |
| **ENV** | Set environment variables. |
| **EXPOSE** | Describe which ports your application is listening on. |
| **FROM** | Create a new build stage from a base image. |
| **HEALTHCHECK** | Check a container's health on startup. |
| **LABEL** | Add metadata to an image. |
| **MAINTAINER** | Specify the author of an image. |
| **ONBUILD** | Specify instructions for when the image is used in a build. |
| **RUN** | Execute build commands. |
| **SHELL** | Set the default shell of an image. |
| **STOPSIGNAL** | Specify the system call signal for exiting a container. |
| **USER** | Set user and group ID. |
| **VOLUME** | Create volume mounts. |
| **WORKDIR** | Change working directory. |