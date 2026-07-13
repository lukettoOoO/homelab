# CLI Build and Run

## `docker build`
- Transforms instructions from Dockerfile into an immutable image
- Example:
```bash
sudo docker build -t web-app:v1
```
`build` - compiles the new set of layers from the dockerfile
`-t web-app:v1` - naming flag (tag), allocates name `web-app` and version `v1`; if version is not specified, docker will automatically apply `:latest`
`.` - the build context (current directory); specifies the local directory whose files will be sent to the docker daemon to be used by instructions such as `COPY`; docker can't copy files which are outside of this specified directory

## `docker run`
- Instantiates an built image, creating an active container with its own filesystem and isolated network
- Example:
```bash
sudo docker run -d -p 8080:80 web-app:v1
```
`-d` (detached mode) - runs the container in the background (asynchronously) and frees the host terminal; without `-d` the logs of the app will block the current terminal and closing of the terminal will stop the container
`-p 8080:80` (port publishing/forwarding) - opens up the container's network to the exterior (`host_port:container_port`); in this case, any traffic that is sent to port `8080` of the host will be automatically redirected to port `80` inside the isolated container
`web-app:v1` - the built image that will be instantiated
`--name` - set the name of the container

## `docker pull`
- Pulls the image from the repository to local environment

## `docker images`
- Displays all the images that exist locally

## `docker start`
- Can be used after `docker stop` to start the container again


## Resource management
- Docker uses two fundamental linux kernel mechanisms: namespaces (which isolate what a process can access/see) and Cgroups/Control groups (which limit and isolate what a process can consume)
- Cgroups establish a strict barrier for RAM memory and swap space which a group of processes can colectively access
- If a process from inside the container tries to allocate more memory than the imposed limit, the kernel activates the Out of Memory (OOM) Killer strictly for that local cgroup; the guilty process from the container is force stopped, while the host system and the rest of the containers from the machine remain completely unaffected
- CPU scheduling
- Cgroups also limits the reading and writing rate (I/O) directly for the physical storage devices
- PIDs limit - limiting the maximum number of processes or threads that can be simultaneously instantiated inside a cgroup
- Management of resources is directly configured trough the specific flags we pass to the docker daemon in the moment of container instantiation
- Example:
```bash
sudo docker run -d \
  --name=isolated-app \
  --memory="512m" \
  --cpus="1.5" \
  --pids-limit=100 \
  web-test:latest
```
- More options in the docker documentation: https://docs.docker.com/reference/cli/docker/container/run/