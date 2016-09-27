#!/bin/sh

# Detects all network hardware & creates services for all installed network hardware
/usr/sbin/networksetup -detectnewhardware

IFS=$'\n'

# Loops through the list of network services containing VPN
for service in $(sudo /usr/sbin/networksetup -listallnetworkservices | grep "VPN" ); do
    /usr/sbin/networksetup -removenetworkservice "${service}"
done

exit 0