#!/bin/sh

# Detects all network hardware & creates services for all installed network hardware
#/usr/sbin/networksetup -detectnewhardware

IFS=$'\n'

# Loops through the list of network services containing VPN
for service in $(/usr/sbin/networksetup -listallnetworkservices | grep "VPN" | grep -v "iRobot VPN Split Global" | grep -v "iRobot VPN Global" | grep -v "iRobot VPN HQ" | grep -v "iRobot VPN Split"); do
    echo "${service}"
    /usr/sbin/networksetup -removenetworkservice "${service}"
done

exit 0