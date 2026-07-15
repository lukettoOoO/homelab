# Containerization

To practice everything I have learned so far I will build a simple but useful python script that sends `GET` requests to my homelab dashboard website in order to check the connection status. Then, I will containerize this script.

- Since my python script is not using any outside dependencies and it is an interpreted language, there is no need for a multi-stage image here

- The commands I used are:
```bash
sudo docker build -t monitor-app .
sudo docker run -d -p 8081:80 --name=http-monitor-app monitor-app
sudo docker ps
sudo docker logs http-monitor-app
```

- The displayed logs are:
```bash
Starting Network Monitor Service...
Check successful: https://olympus-luca.online returned HTTP 200
Check successful: https://olympus-luca.online returned HTTP 200
Check successful: https://olympus-luca.online returned HTTP 200
Check successful: https://olympus-luca.online returned HTTP 200
Check successful: https://olympus-luca.online returned HTTP 200
Check successful: https://olympus-luca.online returned HTTP 200
Check successful: https://olympus-luca.online returned HTTP 200
Check successful: https://olympus-luca.online returned HTTP 200
Check successful: https://olympus-luca.online returned HTTP 200
Check successful: https://olympus-luca.online returned HTTP 200
Check successful: https://olympus-luca.online returned HTTP 200
Check successful: https://olympus-luca.online returned HTTP 200
```