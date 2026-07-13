# CLI Debugging and Inspecting

## `docker logs`
- By using `docker logs [container-id]` or `docker logs [container-name]` we can check the logs of a running container for troubleshooting

## `docker exec`
- Using this we can access the terminal of a running container as a root user (ex. for filesystem navigation)
- It runs a new command in a running container (in the default working directory of the container)
- The command must be an executable
- A chained or a quoted command doesn't work
- This works: `docker exec -it my_container sh -c "echo a && echo b"`
- This doesn't work: `docker exec -it my_container "echo a && echo b"`
`-it` - Interactive terminal
- Use `exit` for exiting the terminal

| Argument | Description | Practical Example |
| :--- | :--- | :--- |
| **-i, --interactive** | Keeps the standard input (STDIN) open for the executed process, allowing you to send commands to the container even if it is not attached to a terminal. | `sudo docker exec -i my_container mysql -u root < backup.sql` |
| **-t, --tty** | Allocates a virtual pseudo-terminal (TTY), mapping the host's keyboard and screen to the internal process to render the shell prompt natively. | `sudo docker exec -t my_container top` |
| **-it** | Combines the interactive and TTY flags. This is the absolute standard for opening an interactive terminal shell session inside a running container. | `sudo docker exec -it my_container bash` |
| **-d, --detach** | Detached mode. Runs the specified command in the background and immediately frees up the host machine's terminal, leaving the process to execute asynchronously. | `sudo docker exec -d my_container python3 long_running_script.py` |
| **-u, --user** | Specifies the username or User ID (UID) under which the command will run. Allows gaining root privileges inside a container configured as non-root by default. | `sudo docker exec -u root my_container apt-get update` |
| **-w, --workdir** | Overrides the default working directory (WORKDIR) defined in the image, forcing the command to execute within the specified path argument. | `sudo docker exec -w /var/log my_container tail -f nginx/error.log` |
| **-e, --env** | Sets or overrides a temporary environment variable, valid strictly for the duration of that specific command's execution inside the container. | `sudo docker exec -e ENV_MODE=dev my_container php artisan migrate` |
| **--privileged** | Disables standard container security barriers and grants the newly created process extended hardware device access privileges on the host machine. | `sudo docker exec --privileged my_container tcpdump -i eth0` |

- Trying to run `docker exec` on a paused container, the command fails:

```bash
# luca @ debian-eos in ~/docker-test [14:52:41] 
$ sudo docker pause dockerfile                
dockerfile

# luca @ debian-eos in ~/docker-test [14:53:45] C:1
$ sudo docker ps              
CONTAINER ID   IMAGE                                               COMMAND                  CREATED          STATUS                   PORTS                                                                                      NAMES
9a558c522117   alpine                                              "/bin/sh"                13 minutes ago   Up 13 minutes (Paused)                                                                                              dockerfile
1b1e2d2511e7   ghcr.io/nextcloud-releases/aio-apache:latest        "/start.sh /usr/bin/…"   13 days ago      Up 13 days (healthy)     80/tcp, 0.0.0.0:11000->11000/tcp, [::]:11000->11000/tcp                                    nextcloud-aio-apache
3b42642e4ce8   ghcr.io/nextcloud-releases/aio-nextcloud:latest     "/start.sh /usr/bin/…"   13 days ago      Up 13 days (healthy)     9000/tcp                                                                                   nextcloud-aio-nextcloud
010def3139de   ghcr.io/nextcloud-releases/aio-imaginary:latest     "/start.sh"              13 days ago      Up 13 days (healthy)                                                                                                nextcloud-aio-imaginary
025c3fa01470   ghcr.io/nextcloud-releases/aio-redis:latest         "/start.sh"              13 days ago      Up 13 days (healthy)     6379/tcp                                                                                   nextcloud-aio-redis
447f3b1cfdd7   ghcr.io/nextcloud-releases/aio-postgresql:latest    "/start.sh"              13 days ago      Up 13 days (healthy)     5432/tcp                                                                                   nextcloud-aio-database
0a41b46f3e2b   ghcr.io/nextcloud-releases/aio-notify-push:latest   "/start.sh"              13 days ago      Up 13 days (healthy)                                                                                                nextcloud-aio-notify-push
29051a125e3b   ghcr.io/nextcloud-releases/all-in-one:latest        "/start.sh"              13 days ago      Up 13 days (healthy)     80/tcp, 8443/tcp, 9000/tcp, 0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp                    nextcloud-aio-mastercontainer
327cd1c8794a   nginx:latest                                        "/docker-entrypoint.…"   4 months ago     Up 2 weeks               0.0.0.0:8000->80/tcp, [::]:8000->80/tcp                                                    homelab-dashboard
160f7482b003   jc21/nginx-proxy-manager:latest                     "/init"                  4 months ago     Up 2 weeks               0.0.0.0:80-81->80-81/tcp, [::]:80-81->80-81/tcp, 0.0.0.0:443->443/tcp, [::]:443->443/tcp   npm

# luca @ debian-eos in ~/docker-test [14:54:14] C:1
$ sudo docker exec dockerfile sh           
Error response from daemon: Container dockerfile is paused, unpause the container before exec
```

## Debugging Example:
```bash
# luca @ debian-eos in ~/docker-test [15:04:41] 
$ sudo docker run -d -p 8081:80 --name=test-debug web-test:latest
088a8abad95dd351bd085b08ad4b24f8022254bf95303977c750c6cfb5006661

# luca @ debian-eos in ~/docker-test [15:05:29] 
$ sudo docker ps -l          
CONTAINER ID   IMAGE             COMMAND                  CREATED          STATUS          PORTS                                     NAMES
088a8abad95d   web-test:latest   "python -m http.serv…"   48 seconds ago   Up 47 seconds   0.0.0.0:8081->80/tcp, [::]:8081->80/tcp   test-debug

# luca @ debian-eos in ~/docker-test [15:06:04] 
$ curl http://localhost:8081                               
docker build success!

# luca @ debian-eos in ~/docker-test [15:07:44] 
$ sudo docker logs test-debug
172.17.0.1 - - [13/Jul/2026 12:07:44] "GET / HTTP/1.1" 200 -

# luca @ debian-eos in ~/docker-test [15:10:29] 
$ sudo docker exec -it test-debug sh    
# echo "hello"
hello
# pwd
/app
# ls -all
total 12
drwxr-xr-x 1 root root 4096 Jun  8 13:40 .
drwxr-xr-x 1 root root 4096 Jul 13 12:04 ..
-rw-r--r-- 1 root root   22 Jun  8 13:40 index.html
# cat index.html
docker build success!
# exit
```