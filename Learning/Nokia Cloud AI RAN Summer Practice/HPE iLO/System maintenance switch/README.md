# HPE iLO Reset via System Maintenance Switch

Resetting the HPE iLO to factory settings using the **System Maintenance Switch** is required when:
- The iLO is unreachable over the network because the iLO NICs are turned off or the iLO network configuration is incorrect.
- It is not possible or convenient to use the UEFI System Utilities to correct the configuration.

> [!NOTE]
> **HPE iLO User Guide:**
> On most servers, this action enables DHCP and activates the iLO Dedicated Network Port.

---

## Procedure

1. **Power Down & Disconnect:** Power off the server and disconnect all power cords from the power supplies.
2. **Open Chassis:** Open the server chassis cover.
3. **Locate Switch:** Locate the **System Maintenance Switch** on the motherboard. 
4. **Set to ON:** Turn the mode switch to the **ON** position. *(Default position is **OFF**, representing the Production security state)*.
5. **Connect Power:** Reconnect the power cords to the power supplies.
6. **Assign IP:** Perform the [DHCP IP assignment procedure](../dhcp-server-for-hpe-ilo/README.md).
7. **Power Down & Disconnect:** After verifying correct IP assignment, power off the server and disconnect the power cords from the power supplies.
8. **Set to OFF:** Turn the mode switch back to the **OFF** position.
9. **Close Chassis:** Replace and secure the server chassis cover.
10. **Reconnect Power:** Reconnect the power cords to the power supplies.
11. **Verify Connectivity:** Verify that iLO is reachable over the network.
