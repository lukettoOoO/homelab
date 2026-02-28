
### What is NGINX
- Highly efficient traffic controller standing between th vast internet and a group of backend servers
1. **Web Server**: It delivers HTML files, images, and videos to the browser; it is fast and uses very little memory compared to older servers like Apache
2. **Reverse proxy**: Most common use; sits in front of the server, manages incoming traffic, provides security, load balancing and caching;
3. **Load Balancer**: Distributes the incoming traffic across multiple servers so no single one gets overwhelmed

### NGINX Terminology
In `.conf` files:
- Key-value pairs are called directives (ex. `worker_proceses  1`)
- Blocks of code are known as context
```Nginx
events {
    worker_connections  1024;
}
```

https://www.youtube.com/watch?v=9t9Mp0BGnyI&t=791s