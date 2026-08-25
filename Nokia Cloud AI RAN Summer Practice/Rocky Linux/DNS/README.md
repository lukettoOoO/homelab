# DNS Delpoyment on Rocky Linux

1. Installing BIND9 `named`:
```bash
sudo dnf install -y bind bind-utils
```
2. Configuring  `/etc/named.conf`
```bash
sudo nano /etc/named.conf
```
- Edit `options` directive like the following example:
```                           
options {
    listen-on port 53 { 127.0.0.1; <ROCKY_SERVER_IP_ADDRESS>; }; # MODIFY HERE - local ip of rocky server; keep in mind that this ip can change due to dhcp
    directory       "/var/named";
    dump-file       "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    
    allow-query     { localhost; <NETWORD_IP_ADDRESS>; }; # MODIFY HERE - the network in which the dns server is allowed to query
    recursion yes;

    dnssec-validation auto;
    managed-keys-directory "/var/named/dynamic";
    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";
};
```
- Define a domain zone:
```
zone "<DOMAIN_NAME>" IN {
        type master;
        file "<DOMAIN_NAME>.zone";
        allow-update { none; };
};
```
3. Create zone file:
```bash
   sudo nano /var/named/<DOMAIN_NAME>.zone
```
- Edit the file using this template:
```
$TTL 86400
@   IN  SOA ns1.<DOMAIN_NAME>. <ADMIN_CONTACT>.<DOMAIN_NAME>. (
        <SERIAL>   ; serial - increment on every change (e.g. YYYYMMDDnn)
        3600       ; refresh (1h)
        1800       ; retry (30m)
        604800     ; expire (1w)
        86400 )    ; minimum TTL

; records:
; dns server (this Rocky Linux instance)
@       IN  NS  ns1.<DOMAIN_NAME>.
ns1     IN  A   <ROCKY_SERVER_IP_ADDRESS>

; other server node(s)
<HOSTNAME>  IN  A   <TARGET_IP_ADDRESS>

; main domain (<DOMAIN_NAME>)
@       IN  A   <TARGET_IP_ADDRESS>

; services routed through reverse proxy on <HOSTNAME>
<SERVICE_1>  IN  A   <TARGET_IP_ADDRESS>    ; description
<SERVICE_2>  IN  A   <TARGET_IP_ADDRESS>    ; description

; wildcard: any subdomain *.<DOMAIN_NAME>
*       IN  A   <TARGET_IP_ADDRESS>
```

4. Set file permissions and check syntax:
```bash
sudo chown named:named /var/named/<DOMAIN_NAME>.zone
sudo chmod 640 /var/named/<DOMAIN_NAME>.zone
sudo named-checkconf
sudo named-checkzone <DOMAIN_NAME> /var/named/<DOMAIN_NAME>.zone
```

5. Reset DNS service and enable on boot:
```bash
sudo systemctl restart named
sudo systemctl enable named
```

6. Open DNS port in firewall
```bash
sudo firewall-cmd --add-service=dns --permanent
sudo firewall-cmd --reload
```

7. Test query from the machine running the DNS server
```bash
dig @<DNS_SERVER_IP> <SUBDOMAIN>.<DOMAIN_NAME>
```
- A respone containing the IP address should be dipslayed instantly

8. Test from a DNS client running on a different machine
```bash
dig @<DNS_SERVER_IP> <SUBDOMAIN>.<DOMAIN_NAME>
```