**Setting up a simple homelab dasboard page with NGINX**
- Decided to create a global homelab dashboard to act as a hub for this node and future nodes that will be added
- For now, its main purpose is to access the main services provided by the servers
- In the future, for easier access, I plan on using PiHole to create a custom domain name for this website
- Directory structure:
```bash
dashboard
├── docker-compose.yml
├── html
│   └── index.html
└── nginx.conf

2 directories, 3 files
```
- `docker-compose.yml`:
```yml
name: olympus-dashboard
services:
  web:
    image: nginx:latest
    container_name: homelab-dashboard
    restart: always
    ports:
      - "8000:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./html:/usr/share/nginx/html:ro
```
- `nginx.conf`:
```Nginx
http {

    include mime.types;

    server {
        listen 80;
        root /usr/share/nginx/html;
    }
}

events {}
```
- Built a simple HTML page (`html/index.html`) with direct links to the services running on Eos (Netdata on port 19999, Nextcloud on port 8080, this website on port 8000)
- The port was blocked by default so I had to explicitly allow the container's traffic:
```bash
sudo ufw-docker allow homelab-dashboard 80
```