# Docker Volumes

- Docker containers are ephemere and once `docker rm` is used, all the data goes away with them.
- To save long-term data, Docker offers two main mechanisms:

| Feature | Named Volumes | Bind Mounts |
| :--- | :--- | :--- |
| **Host Location** | Fully managed by Docker (on Linux: `/var/lib/docker/volumes/`). | Any existing folder or file on your computer (e.g., `~/projects/app`). |
| **Control** | Isolated from the host operating system; regular users should not modify files directly on the disk. | Full control for the host; you can open the folder in VS Code and modify files live. |
| **Mounting Behavior** | If the folder inside the container already contains files, Docker automatically copies them into the empty volume upon the first startup. | The folder from the host completely overwrites/hides the contents of the folder inside the container. |
| **Optimal Use Case** | Databases (PostgreSQL, MySQL) or production files that require raw I/O performance. | Development phase, to send code saved in VS Code directly into the container without rebuilding the image. |

- A Docker volume is a folder in a physical host file system that is mounted into the virtual file system of Docker
- Even when the container is first started, it automatically gets the data from the host
- 3 Docker volume types:
    - Host volumes: `docker run -v /home/mount/data:/var/lib/mysql/data` (the connection to the host directory and the container directory)
    - Anonymous volumes: `docker run -v /var/lib/mysql/data` (just referencing the container directory, the host directory is automatically created by docker under `var/lib/docker/volumes`)
    - Named volumes: `docker run -v name:/var/lib/mysql/data` (specifies the name of a Docker-managed volume, not a specific host folder path - this is mostly used)

## Bind Mounts
- Bind mounts are a technique that enables you to associate any directory on the host machine directly with a directory within the container
- It allows access to files or directories stored anywhere on the host
- Since they aren't isolated by Docker, both non-Docker processes on the host and container processes can modify the mounted files simultaneously
- Bind mounts are used when we want to be able to access files from both the container and the host
- Bind mounts are used using the `-v"$(pwd)":/app` (for example) in the `docker run` command


