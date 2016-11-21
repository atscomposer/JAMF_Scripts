#!/bin/sh

# Detects all network hardware & creates services for all installed network hardware
/usr/sbin/networksetup -detectnewhardware

#IFS=$'\n'

echo "<result>`/usr/sbin/networksetup -listallnetworkservices | grep "iRobot VPN"*`</result>"
exit 0