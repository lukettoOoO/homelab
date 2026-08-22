### Installing Nextcloud
- I want a service that helps with system backups but also to help me store my own files in a local cloud storage
- The scope is to be also used by my family
- I will use Nextcloud AIO
- `.yml` file for docker compose
```yml
name: nextcloud-aio
services:
  nextcloud-aio-mastercontainer:
    image: ghcr.io/nextcloud-releases/all-in-one:latest
    init: true
    restart: always
    container_name: nextcloud-aio-mastercontainer
    volumes:
      - nextcloud_aio_mastercontainer:/mnt/docker-aio-config
      - /var/run/docker.sock:/var/run/docker.sock:ro
    network_mode: bridge
    ports:
      - 8080:8080
    environment:
      NEXTCLOUD_DATADIR: /srv/docker/nextcloud/ncdata
      APACHE_PORT: 11000

volumes:
  nextcloud_aio_mastercontainer:
    name: nextcloud_aio_mastercontainer
```
- In the future I will be using a custom domain, that's why I've set `APACHE_PORT: 11000`
- I set up the following directory structure:
```
 nextcloud
    ├── compose.yml
    └── ncdata
```
- Using `ncdata` for host directory where all files uploaded to NextCloud will be stored
- Running `docker-compose up -d` to start everything up


**Setting up NGINX for Nextcloud**
- To serve Nextcloud under a custom domain
- Nextcloud AIO's Apache server is tucked away on a port; users shouldn't have to type that port at the end of my URL, so NGINX listens on the standard port `443` (HTTPS) and silently passes that traffic to Nextcloud in the background
- By default, web servers block large uploads (often at 1MB); by using NGINX I will be able to send a 10GB file through the server, for example
- NGINX can help with using clean domain names (ex. `cloud.example.com`) to reach multiple services using only one open firewall port (`443`)
- I will set up NGINX proxy manager GUI as a new Docker continer
https://hub.docker.com/r/jc21/nginx-proxy-manager
- Bought a public domain: olympus-luca.online
- Set it up on Cloudflare with DNS records and changed the current nameservers with Cloudflare nameservers on the domain proivder website
- Generated Cloudflare API token
- Now the domain is being managed completely on Cloudflare
- Creating Let's Encrypt certificte on NPM to remove "Not secure" warning
- Rather than opening my home router ports to the public internet, I opted for a high-security configuration that points my public domain (olympus-luca.online) directly to my local server IP (192.168.1.200)
- In Cloudflare, I configured a CNAME wildcard (*) record, ensuring that any subdomain I create—such as nc. for Nextcloud or dash. for my dashboard—automatically routes to my Debian server without needing individual DNS entries for every new service
- To obtain a valid SSL certificate without public port exposure, I utilized the DNS-01 Challenge; by providing NPM with my Cloudflare API token, it successfully "shook hands" with Cloudflare to prove domain ownership behind the scenes, granting me a professional Wildcard SSL Certificate (*.olympus-luca.online)
- Configured AIO Nextcloud and main Nextcloud domain using NPM along with other domains for my homelab (Netdata and dashboard)
```
Proxy Host Configurations:
1. nc.olympus-luca.online -> http://192.168.1.200:11000 (Main Nextcloud Instance)
2. nc-aio.olympus-luca.online -> https://192.168.1.200:8080 (AIO Mastercontainer Setup)
3. nd.olympus-luca.online -> http://192.168.1.200:19999 (Netdata Console)
4. olympus-luca.online -> http://192.168.1.200:8000 (Root Domain / Main Site)
```
- Nextcloud is now up and running
- Set up admin account with email and password