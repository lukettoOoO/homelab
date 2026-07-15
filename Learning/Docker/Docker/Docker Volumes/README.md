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
```bash
docker run --mount type=bind,src=<host-path>,dst=<container-path>
docker run --volume <host-path>:<container-path>
```

## Example:
```bash
# luca @ debian-eos in /srv/test/docker-test/volumes [16:41:20] C:1
$ sudo docker volume create data-test
data-test

# luca @ debian-eos in /srv/test/docker-test/volumes [16:41:28] 
$ sudo docker volume inspect data-test
[
    {
        "CreatedAt": "2026-07-15T16:41:27+03:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/srv/docker-data/volumes/data-test/_data",
        "Name": "data-test",
        "Options": null,
        "Scope": "local"
    }
]

# luca @ debian-eos in /srv/test/docker-test/volumes [16:43:55] 
$ sudo docker run -d --name web-volume -p 8090:80 -v data-test:/usr/share/nginx/html nginx:latest
f1b2e2a850302f22f2caa7fe11db61d16713e72f6b0bdb05da0a46b2a598b464

# luca @ debian-eos in /srv/test/docker-test/volumes [16:44:00] 
$ curl http://localhost:8090
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

# luca @ debian-eos in /srv/test/docker-test/volumes [16:45:27] 
$ sudo docker exec -it web-volume bash                                                            
root@f1b2e2a85030:/# echo "Data persistence!" > /usr/share/nginx/html/index.html
root@f1b2e2a85030:/# cat /usr/share/nginx/html/index.html
Data persistence!
root@f1b2e2a85030:/# exit
exit

 luca @ debian-eos in /srv/test/docker-test/volumes [16:47:12] 
$ sudo docker rm -f web-volume                                                                   
web-volume

# luca @ debian-eos in /srv/test/docker-test/volumes [16:47:26] 
$ curl http://localhost:8090
curl: (7) Failed to connect to localhost port 8090 after 0 ms: Could not connect to server

# luca @ debian-eos in /srv/test/docker-test/volumes [16:48:06] C:7
$ sudo docker run -d --name web-volume-new -p 8091:80 -v data-test:/usr/share/nginx/html nginx:latest
4d90d8ba83e3aa7cdd17237ee9ec9a69d99c71aa6dd1f290dadcf11732fbea06

# luca @ debian-eos in /srv/test/docker-test/volumes [16:49:34] C:7
$ curl http://localhost:8091
Data persistence!
```
