## VLANs (Part 2)

### Network Topology:
![1](network_topology.png)

- There is no link in VLAN20 between SW1 and SW2.
- This is because there are no PCs in VLAN20 connected to SW1.
- PCs in VLAN20 can still reach PCs connected to SW1, R1 will perform inter-VLAN routing.

### Trunk Ports:
- In a small network with few VLANs, it is possible to use a separate interface for each VLAN when connecting switches to switches, and switches to routers
- However, when the number of VLANs increases, this is not viable. It will result in wasted interfaces, and often routers won't have enough interfaces for each VLAN.
- You can use **trunk ports** to carry traffic from multiple VLANs over a single interface.
- Switches will 'tag' all frames that they send over a trunk link.
- This allows the receiving switch to know which VLAN the frame belongs to.
```
Trunk ports = 'tagged' ports
Access ports = 'untagged' ports
```
![2](trunk_ports.png)

- There are two main trunking protocols: ISL (Inter-Switch Link) and IEEE 802.1Q (dot1q)
- ISL is an old Cisco proprietary protocol created before the industry standard **IEEE 802.1Q**
- IEEE 802.1Q is an industry standard protocol created by the IEEE (Institute of Electrical and Electronics Engineers)

#### Ethernet Frame:

![3](ethernet_frame.png)
![4](ethernet_header_with_tag.png)

- The 802.1Q tag is inserted between the **Source** and **Type/Length** fields of the Ethernet frame.
- The tag is 4 bytes (32 bits) in length.
- The tag consists of two main fields: 
    - Tag Protocol Identifier (TPID)
    - Tag Control Information
- The TCI consists of three sub-fields

![5](tag_format.png)

#### 802.1Q Tag - TPID (Tag Protocol Identifier)
- 16 bits (2 bytes) in length
- Always set to a value of `0x8100`. This indicates that the frame is 802.1Q-tagged.

#### 802.1Q Tag - PCP (Priority Code Point)
- 3 bits in length
- Used for Class of Service (CoS), which prioritizes important traffic in congested networks.

#### 802.1Q Tag - DEI (Drop Eligible Indicator)
- 1 bit in length
- Used to indicate frames that can be dropped if the network is congested.

#### 802.1Q Tag - VID (VLAN ID)
- 12 bits in length
- Identifies the VLAN the frame belongs to.
```bash
12 bits in length = 4096 total VLANs (2^12), range of 0 - 4095
```
- VLANs 0 and 4095 are reserved and can't be used.
- Therefore, the actual range of VLANs is 1 - 4094

### VLAN Ranges
- The range of VLANs (1 - 4094) is divided into two sections:
    - Normal VLANs: 1 - 1005
    - Extended VLANs: 1006 - 4094
- Some older devices cannot use the extended VLAN range, however it's safe to expect that modern switches will support the extended VLAN range.

### Native VLAN
- 802.1Q has feature called the **native VLAN**
- The native VLAN is VLAN 1 by default on all trunk ports however this can be manually configured on each trunk port.
- The switch does not add an 802.1Q tag to frames in the native VLAN.
- When a switch receives an untagged frame on a trunk port, it assumes the frame bleongs to the native VLAN. **It's very important that the native VLAN matches!**
- If traffic in the native VLAN, it doesn't need to be tagged.
![5](native_vlan.png)
![6](native_vlan_error.png)

### Trunk configuration
![7](trunk_configuration.png)

- Many modern switches do not support Cisco's ISL at all; they only support 802.1Q (dot1q)
- However, switches that do support both (like the one used in this example) have a trunk encapsulation of 'Auto' by default
- To manually configure the interface as a trunk port, the encapsulation must be set to 802.1Q or ISL. On switches that only support 802.1Q, this is not necessary.
- After the encapsulation type is set, the interface can be configured as a trunk.
![8](trunk_config.png)
![9](trunk_config1.png)
![10](trunk_config2.png)
![11](trunk_config3.png)
![12](trunk_config4.png)
![13](trunk_config5.png)
![14](trunk_config6.png)
![15](trunk_config7.png)
![16](trunk_config8.png)

- For our configuration:
![17](trunk_config_example.png)
- For security purposes, it is best to change the native VLAN to an **unused VLAN**.
- **Make sure the native VLAN matches on between switches.**
![18](trunk_config_example1.png)
![19](trunk_config_example2.png)
- The **`show vlan brief`** command shows the access ports assigned to each VLAN, NOT the trunk ports that allow each VLAN.
- Use **`show interfaces trunk`** command instead to confirm trunk ports.

![20](trunk_config_example3.png)
![21](trunk_config_example4.png)

### Router on a Stick (ROAS)
![22](router_on_a_stick.png)

![23](roas_example1.png)
- The subinterface number **does not** have to match the VLAN number.
- However it is **highly recommended** that they do match, to make it easier to understand.

![24](roas_example.png)

![25](roas_example2.png)

- ROAS is used to route between multiple VLANs using a single interface on the router and switch
- The switch interface is configured as a regular trunk
- The router interface is configured using **subinterfaces**; you configure the VLAN tag and IP address on each subinterface
- The router will behave as if frames with a certain VLAN tag have arrived on the subinterface configured with that VLAN tag
- The router will tag frames sent out of each subinterface with the VLAN tag configured on the subinterface.

### Quiz
1. You want to configure `SW1` to send `VLAN10` frames untagged over its `GigabitEthernet0/1` interface, a trunk. Which command is appropriate?

*d) `switchport trunk native vlan 10`*

2. After modifying the list of VLANs allowed on a trunk interface, you want to return it to the default state. Which command will do this?

*b) `switchport trunk allowed vlan all`*

3. You try to configure an interface on a Cisco switch as a trunk port with the command **`switchport mode trunk`**, but the command is rejected. Which command might fix this issue.

*c) `switchport trunk encapsulation dot1q`*

4. Which field of the 802.1Q tag identifies the VLAN ID of the frame?

*b) VID*

5. You configured **`switchport trunk allowed vlan add 10`** on an interface, but VLAN10 doesn't appear in the **`Vlans allowed and active in management domain`** section of the **`show interfaces trunk`** command output. What might be the reason?

*a) `VLAN10` doesn't exist on the switch.*