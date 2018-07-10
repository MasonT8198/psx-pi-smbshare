#!/bin/bash

#
# psx-pi-smbshare setup script
#
# *What it does*
# This script will install and configure an smb share at /share
# It will also compile ps3netsrv from source to allow operability with PS3/Multiman
# Finally, it configures the pi ethernet port to act as dhcp server for connected devices and allows those connections to route through wifi on wlan0
#
# *More about the network configuration*
# This configuration provides an ethernet connected PS2 or PS3 a low-latency connection to the smb share running on the raspberry pi
# The configuration also allows for outbound access from the PS2 or PS3 if wifi is configured on the pi
# This setup should work fine out the box with OPL and multiman
# Per default configuration, the smbserver is accessible on 192.168.2.1

#Working directory
cd /home/pi

# Update packages
sudo apt-get -y update
sudo apt-get -y upgrade

# Install and configure Samba
sudo apt-get install -y samba samba-common-bin

sudo mkdir -m 1777 /share

sudo cat <<'EOF' | sudo tee /etc/samba/smb.conf
[global]
workgroup = WORKGROUP
usershare allow guests = yes
map to guest = bad user
allow insecure wide links = yes
[share]
Comment = Pi shared folder
Path = /share
Browseable = yes
Writeable = Yes
only guest = no
create mask = 0777
directory mask = 0777
Public = yes
Guest ok = yes
force user = pi
follow symlinks = yes
wide links = yes
EOF

#if you wish to create a samba user with password you can use the following:
#sudo smbpasswd -a pi
sudo /etc/init.d/samba restart

# Install ps3netsrv
sudo apt-get install -y git gcc
git clone https://github.com/dirkvdb/ps3netsrv--.git
cd ps3netsrv--
git submodule update --init
make CXX=g++
sudo cp ps3netsrv++ /usr/local/bin


# Install wifi-to-eth route settings
sudo apt-get install -y dnsmasq
wget https://raw.githubusercontent.com/toolboc/psx-pi-smbshare/master/wifi-to-eth-route.sh -O /home/pi/wifi-to-eth-route.sh
chmod 755 ./wifi-to-eth-route.sh

# Install setup-wifi-access-point settings
sudo apt-get install -y hostapd bridge-utils
wget https://raw.githubusercontent.com/toolboc/psx-pi-smbshare/master/setup-wifi-access-point.sh -O /home/pi/setup-wifi-access-point.sh
chmod 755 ./setup-wifi-access-point.sh

# Install Xlink Kai
wget http://cdn.teamxlink.co.uk/binary/kaiEngine-7.4.31-rev606.headless.ARM.tar.gz
tar -xzvf kaiEngine-7.4.31-rev606.headless.ARM.tar.gz
sudo cp kaiEngine-7.4.31/kaiengine /usr/local/bin
sudo mkdir /root/.xlink

cat <<'EOF' > /home/pi/launchkai.sh
while true; do
    /usr/local/bin/kaiengine
    sleep 1
done
EOF

chmod 755 launchkai.sh

# Install USB automount settings
wget https://raw.githubusercontent.com/toolboc/psx-pi-smbshare/master/automount-usb.sh -O /home/pi/automount-usb.sh
chmod 755 ./automount-usb.sh
sudo ./automount-usb.sh

mkdir -m 1777 /share/USB

# Set wifi-to-eth-route, setup-wifi-access-point, ps3netsrv, and Xlink Kai to run on startup
{ echo -e "@reboot sudo bash /home/pi/wifi-to-eth-route.sh && sudo bash /home/pi/setup-wifi-access-point.sh\n@reboot /usr/local/bin/ps3netsrv++ -d /share/\n@reboot sudo bash /home/pi/launchkai.sh"; } | crontab -u pi -

# Start services
sudo /home/pi/wifi-to-eth-route.sh
sudo /home/pi/setup-wifi-access-point.sh
ps3netsrv++ -d /share/
sudo kaiengine

# Not a bad idea to reboot
sudo reboot