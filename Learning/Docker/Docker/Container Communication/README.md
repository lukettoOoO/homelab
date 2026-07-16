# Container Communication

## The Default Bridge

- The Docker Bridge is the default network in Docker
``` bash
# luca @ debian-eos in /srv/test/docker-test [17:17:46] 
$ ip address show | grep "docker0"
8: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
101: veth55e66a7@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
106: veth3d80db5@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
```

- Current Docker networks:
```bash
# luca @ debian-eos in /srv/test/docker-test [17:19:07] 
$ sudo docker network ls  
NETWORK ID     NAME                          DRIVER    SCOPE
331a112d5b35   bridge                        bridge    local
cee8f4bfd617   docker_default                bridge    local
453e4923db56   host                          host      local
09e953be4f29   nextcloud-aio                 bridge    local
8b2a525a2593   nginx-proxy-manager_default   bridge    local
3ab9f7442bdb   none                          null      local
06df0dbc4d46   olympus-dashboard_default     bridge    local
```
- Driver = network type

```bash
# luca @ debian-eos in /srv/test/docker-test [17:36:44] 
$ sudo docker run -itd --rm --name thor busybox                                                      
Unable to find image 'busybox:latest' locally
latest: Pulling from library/busybox
b05093807bb0: Pull complete 
7270b3e1860c: Download complete 
Digest: sha256:fd8d9aa63ba2f0982b5304e1ee8d3b90a210bc1ffb5314d980eb6962f1a9715d
Status: Downloaded newer image for busybox:latest
d57d78f0d5b820f572ef2194766caad2ceeeeefe4513add74ce9972a6a4dbc20

# luca @ debian-eos in /srv/test/docker-test [17:37:12] 
$ sudo docker run -itd --rm --name mjolnir busybox 
92fb9084c2184b1acd28ddad055513954f2b44188718030b19f09b6a99b01be2

# luca @ debian-eos in /srv/test/docker-test [17:37:33] 
$ sudo docker run -itd --rm --name stormbreaker nginx  
a473e35bce82ec777490bfe64549f00ad3e83823f67768c25d70499e67c77431
```
- Docker automatically created 3 virtual ethernet interfaces and connected them to the `docker0` bridge that acts like a switch

```bash
# luca @ debian-eos in /srv/test/docker-test [17:42:26] 
$ sudo docker inspect bridge
[
    {
        "Name": "bridge",
        "Id": "331a112d5b35d8067d5e5a9654cb6baa4e2b7af00dad5842f4a583b96401fc16",
        "Created": "2026-07-13T16:09:52.052509146+03:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv4": true,
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {},
        "Containers": {
            "00e59167b0d6b8f8ab2baae8e68587f58205d511cb2f9a76091648981a7f63df": {
                "Name": "http-monitor-app",
                "EndpointID": "095a0704a8d126eddf4bb76fb0414fc91e9734c3dcb8a41d23eddff24cccfe4b",
                "MacAddress": "12:ad:ac:09:d6:57",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            },
            "92fb9084c2184b1acd28ddad055513954f2b44188718030b19f09b6a99b01be2": {
                "Name": "mjolnir",
                "EndpointID": "f1c0eb7f35747b842234d47e6e29635ea96b755a2e976a80523353cda9027850",
                "MacAddress": "5e:fe:68:5a:d6:82",
                "IPv4Address": "172.17.0.4/16",
                "IPv6Address": ""
            },
            "a473e35bce82ec777490bfe64549f00ad3e83823f67768c25d70499e67c77431": {
                "Name": "stormbreaker",
                "EndpointID": "74c56e8c3fd4a9aeaa4798544cd400dfb5711296bbece9ac507825034ebf4482",
                "MacAddress": "b2:ad:07:ea:a5:9e",
                "IPv4Address": "172.17.0.5/16",
                "IPv6Address": ""
            },
            "d57d78f0d5b820f572ef2194766caad2ceeeeefe4513add74ce9972a6a4dbc20": {
                "Name": "thor",
                "EndpointID": "7085c2a769d209862e9e10bb44261d5dd856ba9e2666a3e99c4d704df2fbaae5",
                "MacAddress": "32:6f:35:a4:c2:68",
                "IPv4Address": "172.17.0.3/16",
                "IPv6Address": ""
            }
        },
        "Status": {
            "IPAM": {
                "Subnets": {
                    "172.17.0.0/16": {
                        "IPsInUse": 7,
                        "DynamicIPsAvailable": 65529
                    }
                }
            }
        }
    }
]
```

- All the containers act like being part of the same local network, because they actually are, connected to the host `docker0` with IP address `172.17.0.0/16`
- For example:
```bash
# luca @ debian-eos in /srv/test/docker-test [17:42:43] 
$ sudo docker exec -it thor sh        
/ # ip add
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0@if108: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue 
    link/ether 32:6f:35:a4:c2:68 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
/ # ping 172.17.0.4
PING 172.17.0.4 (172.17.0.4): 56 data bytes
64 bytes from 172.17.0.4: seq=0 ttl=64 time=0.141 ms
64 bytes from 172.17.0.4: seq=1 ttl=64 time=0.075 ms
64 bytes from 172.17.0.4: seq=2 ttl=64 time=0.067 ms
64 bytes from 172.17.0.4: seq=3 ttl=64 time=0.078 ms
64 bytes from 172.17.0.4: seq=4 ttl=64 time=0.074 ms
64 bytes from 172.17.0.4: seq=5 ttl=64 time=0.075 ms
64 bytes from 172.17.0.4: seq=6 ttl=64 time=0.086 ms
64 bytes from 172.17.0.4: seq=7 ttl=64 time=0.070 ms
64 bytes from 172.17.0.4: seq=8 ttl=64 time=0.070 ms
64 bytes from 172.17.0.4: seq=9 ttl=64 time=0.076 ms
64 bytes from 172.17.0.4: seq=10 ttl=64 time=0.056 ms
64 bytes from 172.17.0.4: seq=11 ttl=64 time=0.076 ms
64 bytes from 172.17.0.4: seq=12 ttl=64 time=0.062 ms
64 bytes from 172.17.0.4: seq=13 ttl=64 time=0.078 ms
64 bytes from 172.17.0.4: seq=14 ttl=64 time=0.073 ms
64 bytes from 172.17.0.4: seq=15 ttl=64 time=0.073 ms
64 bytes from 172.17.0.4: seq=16 ttl=64 time=0.083 ms
64 bytes from 172.17.0.4: seq=17 ttl=64 time=0.075 ms
64 bytes from 172.17.0.4: seq=18 ttl=64 time=0.076 ms
64 bytes from 172.17.0.4: seq=19 ttl=64 time=0.090 ms
64 bytes from 172.17.0.4: seq=20 ttl=64 time=0.085 ms
64 bytes from 172.17.0.4: seq=21 ttl=64 time=0.070 ms
^C
--- 172.17.0.4 ping statistics ---
22 packets transmitted, 22 packets received, 0% packet loss
round-trip min/avg/max = 0.056/0.077/0.141 ms
```

- Containers also have access to the internet:
```bash
/ # ping google.com
PING google.com (192.178.24.174): 56 data bytes
64 bytes from 192.178.24.174: seq=0 ttl=114 time=57.463 ms
64 bytes from 192.178.24.174: seq=1 ttl=114 time=57.277 ms
64 bytes from 192.178.24.174: seq=2 ttl=114 time=57.621 ms
^C
--- google.com ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 57.277/57.453/57.621 ms
```
- That is because `172.17.0.1` is the gateway address for these docker containers
```bash
/ # ip route
default via 172.17.0.1 dev eth0 
172.17.0.0/16 dev eth0 scope link  src 172.17.0.3 
```

- The ports of the containers in the bridged network have to be manually exposed using `p` in `docker run` in order to be reached from outside machines

## The User-defined Bridge
- Creating custom bridge:
```bash
# luca @ debian-eos in /srv/test/docker-test [17:56:50] 
$ sudo docker network create asgard   
7efd6e805ce509c7faacde6dc18587a257dda05aaf24359525813097f3f38e6
```

- The custom user-defined bridge has been created:
```bash
# luca @ debian-eos in /srv/test/docker-test [17:59:01] 
$ sudo docker network ls           
NETWORK ID     NAME                          DRIVER    SCOPE
7efd6e805ce5   asgard                        bridge    local # the result
331a112d5b35   bridge                        bridge    local
cee8f4bfd617   docker_default                bridge    local
453e4923db56   host                          host      local
09e953be4f29   nextcloud-aio                 bridge    local
8b2a525a2593   nginx-proxy-manager_default   bridge    local
3ab9f7442bdb   none                          null      local
06df0dbc4d46   olympus-dashboard_default     bridge    local
```

```bash
# luca @ debian-eos in /srv/test/docker-test [18:00:10] 
$ sudo docker run -itd --rm --network asgard --name loki busybox
c33ab34b988ed1964a39b8ebb193261357937d2f4a995cd504aece57143ed1f1

# luca @ debian-eos in /srv/test/docker-test [18:01:34] 
$ sudo docker run -itd --rm --network asgard --name odin busybox
ae9674d2f8a72d408f9f050750c9a069d2df862842a4ef900b31886cc1ade201

# luca @ debian-eos in /srv/test/docker-test [18:01:44] 
$ sudo docker inspect asgard                                    
[
    {
        "Name": "asgard",
        "Id": "7efd6e805ce509c7faacde6dc18587a257dda05aaf24359525813097f3f38e63",
        "Created": "2026-07-15T17:59:00.179353173+03:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv4": true,
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.19.0.0/16",
                    "Gateway": "172.19.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Options": {},
        "Labels": {},
        "Containers": {
            "ae9674d2f8a72d408f9f050750c9a069d2df862842a4ef900b31886cc1ade201": {
                "Name": "odin",
                "EndpointID": "c57cd7fd3031b9c95982aac98c7c12f52c234b48c465e232fe68176512fa9ba2",
                "MacAddress": "6a:92:2c:fa:0c:d1",
                "IPv4Address": "172.19.0.3/16",
                "IPv6Address": ""
            },
            "c33ab34b988ed1964a39b8ebb193261357937d2f4a995cd504aece57143ed1f1": {
                "Name": "loki",
                "EndpointID": "9e15069ef200378ba51863ceca7cb942bca60e96ee3bd4084cb856ea5a6909e6",
                "MacAddress": "d2:22:2f:37:8c:ab",
                "IPv4Address": "172.19.0.2/16",
                "IPv6Address": ""
            }
        },
        "Status": {
            "IPAM": {
                "Subnets": {
                    "172.19.0.0/16": {
                        "IPsInUse": 5,
                        "DynamicIPsAvailable": 65531
                    }
                }
            }
        }
    }
]
```

- If we ping `loki` or `odin` from `thor` for example we can see that they are not reachable becasue they are in different networks
- User-defined bridges are recommended

## The Host Network
- When a container is deployed to the host network, it doesn't really own its own network
- It shares the same network as the host
- Ports don't have to be exposed

## MACVLAN
- In a MACVLAN network, the container's ethernet interfaces are connecting drectly to a switch
- They get their own Mac addresses and have their own IP addresses on a host network

- Creating and running a container in a MACVLAN
```bash
# luca @ debian-eos in /srv/test/docker-test [19:02:51] C:1
$ sudo docker network create -d macvlan \
> --subnet 192.168.1.0/24 \
> --gateway 192.168.1.1 \
> -o parent=wlp3s0 \
> newasgard       
5c46a0717260ffed51af47b000672b2074b62aeb95d353608023d5c969a0e285

# luca @ debian-eos in /srv/test/docker-test [19:07:17] 
$ sudo docker network ls                 
NETWORK ID     NAME                          DRIVER    SCOPE
7efd6e805ce5   asgard                        bridge    local
331a112d5b35   bridge                        bridge    local
cee8f4bfd617   docker_default                bridge    local
453e4923db56   host                          host      local
5c46a0717260   newasgard                     macvlan   local
09e953be4f29   nextcloud-aio                 bridge    local
8b2a525a2593   nginx-proxy-manager_default   bridge    local
3ab9f7442bdb   none                          null      local
06df0dbc4d46   olympus-dashboard_default     bridge    local

# luca @ debian-eos in /srv/test/docker-test [19:07:28] 
$ sudo docker stop thor mjolnir
thor
mjolnir

# luca @ debian-eos in /srv/test/docker-test [19:08:37] 
$ sudo docker run -itd --rm --network newasgard \                   
> --ip 192.168.1.220 \
> --name thor busybox
4a28b655c2afaceb9f6253a17c00ff4b01c4c95a2f6c04334b09bf098e3da675
```

## IPVLAN

- In IPVLAN L2, each container can receive its own IP address, but it allows the host to share its MAC address with the containers
- In IPVLAN L3, each container is not connected to the host like it's a switch, it is connecting to the host like it's a router
- In IPVLAN L4, the networking is abstracted using overlay

## None

- Completely isolate a container from the host and other containers

## Essential Command Examples:
```bash
sudo docker network create homelab-network
sudo docker run -d --name web-service --network homelab-network nginx:latest
sudo docker run --rm --network homelab-network alpine wget -qO- http://web-service
```
