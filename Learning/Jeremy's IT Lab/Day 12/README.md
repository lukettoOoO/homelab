## The Life of a Packet

![1](network_topology.png)
- Assuming staic route through R2

![2](arp_request.png)
- Broadcast destination MAC address

![3](arp_reply.png)

![4](send_frame_to_r1.png)

- PC1 sends the ethernet frame to R1 which removes the header and looks up in its routing table for the next hop
![5](r1_to_r2.png)

![6](arp_request_1.png)
![7](arp_reply_1.png)

![8](send_frame_to_r2.png)

![9](r2_to_r4.png)

![10](arp_request_2.png)
![11](arp_reply_2.png)

![12](send_frame_to_r4.png)

![13](r4_to_pc4.png)

![14](arp_request_3.png)
![15](arp_reply_3.png)

![16](send_frame_to_pc4.png)

- If we send another packet from PC4 to PC1, no ARP requests will be longer needed
![17](PC4_to_PC1.png)

### Quiz

1. PC4 sends a packet to PC1. What is the **destination MAC addres** when it is sent from **PC4's network interface**?
*`fffe`*

2. PC4 sends a packet to PC1. What is the **source MAC addrss** when itis received on **R1's g0/0 interface**?
*`cccc`*

3. PC4 sends a packet to PC1. What is the **source MAC address** when it is sent from **SW1's g0/1 interface**?
*`aaaa`*

4. PC4 sends a packet to PC1. What is the **destination IP address** when it is sent from **R4's g0/1 interface**?
*`192.168.1.1`*

5. PC4 sends a packet to PC1. What is the **source IP address** when it is received on **R1's g0/0 interface**?
*`192.168.4.1`*

