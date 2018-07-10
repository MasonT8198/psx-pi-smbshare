# psx-pi-smbshare
SMB sharing for Multiman and Open Playstation Loader on Raspberry Pi

## How it works
psx-pi-smbshare is a preconfigured Raspbian based image for Raspberry Pi 1, 2, and  3.  It runs a [Samba](https://en.wikipedia.org/wiki/Samba_(software)) share, a pi-compatible build of [ps3netsrv](https://github.com/dirkvdb/ps3netsrv--), and reconfigures the ethernet port to act as a router.  This gives low-latency, direct access to the Samba service through an ethernet cable connection between a PS2/PS3 and Raspberry Pi.  This configuration is achieved by running [setup.sh](/setup.sh).  A pre-supplied [image](https://github.com/toolboc/psx-pi-smbshare/releases/download/v1.2/psx-smbshare-raspbian-stretch-lite.img) can be applied directly to a Micro-SD card using something like [etcher.io](https://etcher.io/).  The image will expand to use the full available space on the SD card when the OS is first booted.

An [Xlink Kai](http://www.teamxlink.co.uk/) client is also included and accesscible at http://smbshare:34522/.  This allows for multi-player gaming over extended LAN.  The service is possible to use on a variety of devices including PS2, PS3, Xbox, Xbox 360, and Gamecube.  Just connect the ethernet cable to the device and access the Xlink Kai Service over Wi-Fi with a smart phone, tablet, or computer.

## What you can do with it
psx-pi-smbshare works out of the box on PS3 with [MultiMAN](http://www.psx-place.com/threads/update2-multiman-v-04-81-00-01-02-base-update-stealth-for-cex-dex-updates-by-deank.12145/).  This functionality allows you to stream and backup up various games and media to the Samba share service running on the Raspberry Pi.

psx-pi-smbshare also works out of the box on PS2 with [Open Playstation Loader](https://github.com/ifcaro/Open-PS2-Loader) and supports streaming of PS2 backups located on the Samba share service. It can also work with [POPStarter for SMB](https://bitbucket.org/ShaolinAssassin/popstarter-documentation-stuff/wiki/smb-mode) to allow streaming of PS1 games from Open Playstation Loader.

psx-pi-smbshare supports an optional ability to route traffic from the ethernet port through a wireless network connection.  When this is configured, the XLink Kai Service can be used on your device.  Xlink Kai will probably work on any device that can access the service via direct ethernet port connection.  This includes Xbox, Gamecube, and PS2.

# Quickstart

** Prequisites **
* Raspberry Pi 1, 2, or 3
* Micro-SD Card (8GB+ suggested)

## Flash the image
Download the latest [psx-pi-smbshare release image](https://github.com/toolboc/psx-pi-smbshare/releases/download/v1.2/psx-smbshare-raspbian-stretch-lite.img) and burn it to a Micro-SD card with [etcher.io](http://etcher.io)

## Configuring Wireless Network
If you wish to configure the wireless network on a Raspberry Pi 2 or 3, you need to add a file to **/boot** on the Micro-SD card.  

Create a file on **/boot** named **wpa_supplicant.conf** and supply the following:

    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
    update_config=1

    network={
            ssid="<SSID>"
            psk="<PASSWORD>"
    }

When the pi is next booted, it will attempt to connect to the wireless network in this configuration.  You are then able to access the raspberry pi on the network and allow for outbound connections from a PS2/PS3 over the wireless network.  
The raspberry pi is configured to have a hostname `smbshare` with a user `pi` and a password of `raspberry`.  

## Accessing the XLink Kai Service
Visit http://smbshare:34522/ or http://<YOUR_PSX_PI_SMBSHARE_DEVICE_IP>:34522/

## Accessing the SMB Share
With a wireless network configured, you should be able to access the SMB share by visiting `\\SMBSHARE\share` on windows or `smb://smbshare/share` on Mac / Linux.

![Accessing SMB](/Assets/smbshare.PNG)

The share is preconfigured with a folder structure to accomodate ps3netsrv and Open Playstation Loader expected file paths.

## Accessing USB drive(s) on the SMB Share
Plug and play auto-sharing of USB storage devices over SMB is supported. 

USB Drives are automounted to the /media directory
USB Drives are available on the SMB Share @ \\SMBSHARE\share\USB\<Filesystem Label>_<Partition>

## Configuring for use with MultiMAN on PS3

** Prequisites **
* Playstation 3 running a [recent release of MultiMAN](http://store.brewology.com/ahomebrew.php?brewid=24)

1. Connect the pi ethernet port into the ethernet port of the PS3 and power the pi using the PS3 usb or an external power supply 
2. In the PS3 XMB select "Settings" => "Network Settings" => "Internet Connection Settings" and configure to connect using the ethernet connection as follows:
    
    "Internet Connection Settings" => "Custom" => "Wired" => "Auto-Detect" => "Manual"

            IP Address = 192.168.2.2
            Subnet Mask = 255.255.255.0
            Default Router = 192.168.2.1
            Primary DNS = 8.8.8.8
            Secondary DNS = <leave blank or use your home router ip address>

    "Automatic" => "Do Not Use" => "Enable"
3. Launch MultiMAN
4. Select "Settings" => "Network Servers"
5. Configure using the Ip Address '192.168.2.1' (ip to the smbshare assigned by dhcp server running on the Pi) and Port '38008' (default)
6. You should see new section for the network server under 'Photos' / 'Music' / 'Video' / 'Retro' and a new location to copy games to when using copy ISO in the 'Games' menu.  

PS3 Games backed up to the network server can be found and loaded from the "Games" menu in MultiMAN.
PS1, PS2, and PSP games can be found and loaded from "Retro" => "PSONE" "PS2" OR "PSP"  
PS2 backups must be loaded from the HDD but can be copied directly to the SMB server.

## Configuring for use with Open Playstation Loader

** Prerequisites **
* Playstation 2 fat or slim running a [recent release of Open Playstation Loader](http://www.ps2-home.com/forum/viewtopic.php?p=29251#p29251) 

1. Connect the pi ethernet port into the ethernet port of the PS2 and power the pi using the PS2 usb or an external power supply 
2. Boot Open Playstation Loader and select "Settings" => "Network Config".  
Ensure that the following options are set:

        Ethernet Link Mode = Auto
        PS2 
            IP address type = Static
            IP address = 192.168.2.2
            Mask = 255.255.255.0
            Gateway = 192.168.2.1
            DNS Server = 8.8.8.8
        SMB Server
            Address Type = IP
            Address = 192.168.2.1
            Port = 445
            Share = share
            Password = <not set>

Don't forget to select "Save Config" when you return to "Settings"

3. Reconnect or restart Open Playstation Loader
4. PS2 Games will be listed under "ETH Games".  To add PS2 games, copy valid .iso backups to `\\SMBSHARE\share\DVD` or `\\SMBSHARE\share\CD`

## Configuring for use with POPSLoader on Open Playstation Loader

** Prerequisites **
* Ensure that you have successfully followed the steps above for "Configuring for use with Open Playstation Loader"

1. Download the [ps2 network modules](https://bitbucket.org/ShaolinAssassin/popstarter-documentation-stuff/downloads/network_modules.7z) 
2. Extract the POPSTARTER folder 
3. Modify IPCONFIG.DAT to:
        
        192.168.2.2 255.255.255.0 192.168.2.1
4. Modify SMBCONFIG.DATA to:
        
        192.168.2.1 share
5. Copy the POPSTARTER folder to your memory card
6. Hop on the internet and look for a copy of a file named "POPS_IOX.PAK" with md5sum "a625d0b3036823cdbf04a3c0e1648901" and copy it to `\\SMBSHARE\share\POPS`.  This file is not included for "reasons".
7. PS1 backups must be converted to .VCD and run through a special renaming program in order to show up in OPL.

    To convert .bin + .cue backups, you can use the included "CUE2POP_2_3.EXE" located in `\\SMBSHARE\share\POPS\CUE2POPS v2.3`
    Copy your .VCD backups to `\\SMBSHARE\share\POPS` then run `\\SMBSHARE\share\POPS\OPLM\OPL_Manager.exe` to rename your files appropriately.
    
    Once converted and properly renamed, your games will show up under the "PS1 Games" section of OPL

    A detailed guide is available @ http://www.ps2-home.com/forum/viewtopic.php?f=64&t=5002

## Playing Halo 2 online with Xlink Kai on Xbox

** Prerequisites **
* An original Xbox or Xbox 360 with backwards compatibility support
* A copy of Halo 2
* An Xlink Kai account from http://www.teamxlink.co.uk/

1. Burn the [latest psx-pi-smbshare image](https://github.com/toolboc/psx-pi-smbshare/releases) to a Micro-SD card
2. Configure Wi-fi per the steps above in ["Configuring the Wireless Network"](https://github.com/toolboc/psx-pi-smbshare#configuring-wireless-network)
3. Plug the pi into the Xbox ethernet port and verify that you are able to obtain an ip automatically in Network Settings
4. Vist the Xlink Kai service running @ http://smbshare:34522 or http://<YOUR_PSX_PI_SMBSHARE_DEVICE_IP>:34522/ and login with your Xlink Kai account
5. Select an available Halo game from the Xlink Kai portal (there are usually a few running in South America)
6. Launch Halo 2 and select "System Link"
7. Join a game and have fun!

## Playing PSP games online with Xlink Kai on PSP
** Prerequisites **
* A Wifi capable PSP system
* 1 external wifi dongle for RPi 2/3 or 2 external wifi dongles for RPi 1

1. Burn the [latest psx-pi-smbshare image](https://github.com/toolboc/psx-pi-smbshare/releases) to a Micro-SD card
2. Plug in the external wifi dongle(s)
3. Configure Wi-fi per the steps above in ["Configuring the Wireless Network"](https://github.com/toolboc/psx-pi-smbshare#configuring-wireless-network)
4. Configure the PSP to connect to "XlinkKai" SSID when the pi has booted using Password `XlinkKai` 
5. Vist the Xlink Kai service running @ http://smbshare:34522 or http://<YOUR_PSX_PI_SMBSHARE_DEVICE_IP>:34522/ and login with your Xlink Kai account
6. Select an available PSP game from the Xlink Kai portal 
7. Start the game on your PSP and look for LAN play settings
8. Join a game and have fun!

## Using a Second WiFi interface as an Access Point to Xlink Kai 
** Prerequisites **
* 1 external wifi dongle for RPi 2/3 or 2 external wifi dongles for RPi 1

1. Burn the [latest psx-pi-smbshare image](https://github.com/toolboc/psx-pi-smbshare/releases) to a Micro-SD card
2. Plug in the external wifi dongle(s)
3. Configure Wi-fi per the steps above in ["Configuring the Wireless Network"](https://github.com/toolboc/psx-pi-smbshare#configuring-wireless-network)
4. Configure the device to connect to "XlinkKai" SSID when the pi has booted using Password `XlinkKai` 

Note: XlinkKai will only work on one network interface (wifi or ethernet) at a time and will lock onto the first interface connected to from a compatible device until reboot

# Credits
Thx to the following:
* Jay-Jay for [OPL Daily Builds](https://github.com/Jay-Jay-OPL/OPL-Daily-Builds) 
* danielb for [OPLM](http://www.ps2-home.com/forum/viewtopic.php?f=64&t=189)
* dirkvdb for [ps3netsrv--](https://github.com/dirkvdb/ps3netsrv--)
* arpitjindal97 for [wifi-to-eth-route.sh](https://github.com/arpitjindal97/raspbian-recipes/blob/master/wifi-to-eth-route.sh)
* Team Xlink for [Xlink Kai](http://www.teamxlink.co.uk/)