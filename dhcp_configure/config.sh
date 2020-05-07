#!/bin/bash

sudo apt install isc-dhcp-server
sudo cp ./iscp-dhcp-server /etc/default/
sudo cp ./dhcpd.conf /etc/dhcp/
sudo systemctl start isc-dhcp-server.service
sudo systemctl enable isc-dhcp-server.service
sudo ufw allow 67/udp
