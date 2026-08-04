# Chapter 2: Podman Basics

## 1. Creating Containers with Podman

### Podman Architecture
* **Daemonless Execution**: Unlike legacy container engines that rely on a central background service, Podman executes without a daemon. This eliminates single-point-of-failure risks and security vulnerabilities associated with root-level background services.
* **Direct Process Control**: Podman interacts directly with Linux kernel namespaces, cgroups, image registries, and container processes.
* **User Interfaces**:
  * **Command-Line Interface (CLI)**: Primary `podman` binary.
  * **RESTful API**: Supports remote automation and tooling integration.
  * **Podman Desktop**: Graphical user interface (GUI) for visual image management, container execution, and OpenShift integration.

### Images & Image Registry Operations
Container images are referenced using the format `NAME:TAG` or fully qualified registry paths:
* `podman pull <registry>/<image>:<tag>`: Downloads a container image to local storage.  
  *Example*: `podman pull registry.access.redhat.com/ubi9/ubi-minimal:9.5`
* `podman images`: Displays locally cached images, including repository, tag, image ID, creation date, and size.

### Container Execution (`podman run`)
Instantiates a container instance from an image and executes the specified command. If the required image is not cached locally, Podman pulls it automatically before execution.

#### Essential `podman run` Flags
* `--name <name>`: Assigns a custom name to the container instance (otherwise Podman generates a random name).
* `--rm`: Automatically removes the container instance and its ephemeral layer upon process exit.
* `-d` (Detached): Executes the container in the background, freeing the terminal.
* `-e KEY="VALUE"`: Sets runtime environment variables inside the container.
* `-p [HOST_IP:]HOST_PORT:CONTAINER_PORT`: Maps host ports to container ports (e.g., `-p 8080:8080` or `-p 127.0.0.1:8080:80`).

---

## 2. Container Networking & DNS Resolution

### Isolated Podman Networks
Podman allows creating custom bridge networks to isolate application tiers (e.g., exposing API-to-UI communication while isolating DB-to-UI access).

### Network Management (`podman network`)
* `podman network create <net_name>`: Provisions a custom container network.
  * *Network Isolation*: `podman network create -o isolate=true <net_name>` prevents cross-network traffic between isolated bridges.
* `podman network ls`: Lists configured container networks.
* `podman network inspect <net_name>`: Displays JSON metadata (including subnet, gateway, and `"dns_enabled"` status).
* `podman network connect <net_name> <container>`: Connects an active container to a network.
* `podman network disconnect <net_name> <container>`: Removes a container from a network.
* `podman network rm <net_name>`: Deletes an unused custom network.

### Rootful vs. Rootless Networking
* **Rootful Networking**: Uses host bridge interfaces. The default system `podman` network has DNS disabled by default.
* **Rootless Networking**: Uses `pasta` (default in Podman 5+) or `slirp4netns` within user network namespaces. Custom networks created in rootless mode have DNS enabled automatically.

### Container Name Resolution (DNS)
* **Custom Networks**: When attached to custom networks with DNS enabled, containers resolve each other by container name (e.g., `http://times-app:8080`).
* **Host Access Shortcuts**:
  * `host.containers.internal` / `host.docker.internal`: Resolves to the host machine's IP address from inside a container.
  * `--add-host=hostname:IP`: Appends custom host-to-IP mappings to the container's `/etc/hosts`.

---

## 3. Accessing & Inspecting Containers

### Container Layer Architecture
* **Image Layers**: Immutable, read-only file system layers.
* **Container Layer**: Volatile, read/write ephemeral storage created when a container starts. Data written here is lost when the container instance is deleted.

### Executing Commands in Running Containers (`podman exec`)
Runs a secondary process inside an existing, active container without restarting it.
* Syntax: `podman exec [options] <container> <command>`
* **Interactive Terminal Access**:  
  `podman exec -ti <container_name> /bin/bash`
  * `-i` (`--interactive`): Keeps `stdin` open for interactive input.
  * `-t` (`--tty`): Allocates a pseudo-terminal.

### Transferring Files (`podman cp`)
Copies files between the host file system and a container instance:
* **Host to Container**: `podman cp /path/file.txt container_name:/target/path/`
* **Container to Host**: `podman cp container_name:/path/error.log ./error.log`
* **Container to Container**: `podman cp containerA:/path/file containerB:/path/`

---

## 4. Container Lifecycle & Query Commands

### Lifecycle Commands
* `podman ps`: Lists active, running containers.
* `podman ps -a` (`--all`): Lists all containers (running, paused, and exited).
* `podman ps --format=json`: Formats output to display full 64-character UUIDs and detailed status parameters.
* `podman port <container_name>`: Displays active host-to-container port mappings.
* `podman inspect <container_name>`: Displays comprehensive configuration metadata in JSON format.
  * *Extract Specific Value*: `podman inspect <container> -f '{{.NetworkSettings.Networks.network_name.IPAddress}}'`
* `podman stop <container_name>`: Sends `SIGTERM` to gracefully stop a running container.
* `podman start <container_name>`: Restarts a stopped container instance.
* `podman rm <container_name>`: Permanently removes a stopped container and its ephemeral layer (`-f` forces removal of running containers).
* `podman rmi <image_id>`: Removes a local container image from storage.
