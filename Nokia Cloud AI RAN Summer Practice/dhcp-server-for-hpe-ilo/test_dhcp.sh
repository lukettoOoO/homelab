#!/bin/bash

INTERFACE="veth-cli"
MAC_ADDR="00:53:00:aa:bb:cc:00:00:00"
CONFIG_CLIENT="/etc/dhcp/dhclient.conf"
CONFIG_SERVER="/etc/dhcp/dhcpd.conf"
CONFIG_ISC_DHCP="/etc/default/isc-dhcp-server"

echo "starting DHCP server test..."
echo "using client config file $CONFIG_CLIENT with test MAC address: $MAC_ADDR"

echo "restarting isc-dhcp-server..."
sudo systemctl restart isc-dhcp-server
sleep 1

echo "releasing old IP address from $INTERFACE..."
sudo dhclient -r -cf $CONFIG_CLIENT $INTERFACE
sudo killall dhclient

echo "simulating a new IP request to the DHCP server..."
echo "DHCP client logs:"
sudo dhclient -v -cf $CONFIG_CLIENT $INTERFACE

echo "allocated IP address on $INTERFACE"
ip -4 addr show $INTERFACE | grep inet

echo "DHCP server logs:"
sudo journalctl -u isc-dhcp-server -n 12 --no-pager | grep dhcpd
