#!/bin/sh

###############################################################################
#
# Name: Remove_Old_VPNs.sh
# Version: 1.0
# Create Date:  20 January 2017
# Last Modified: 14 June 2017
#
# Author:  Adam Shuttleworth
# Purpose:  This script removes VPN network connections based on the connection name
# 
#
###############################################################################

# Detects all network hardware & creates services for all installed network hardware
#/usr/sbin/networksetup -detectnewhardware

IFS=$'\n'

# Loops through the list of network services containing VPN
for service in $(/usr/sbin/networksetup -listallnetworkservices | grep "VPN" | grep -v "VPN Split Global" | grep -v "VPN Global" ); do
    echo "${service}"
    /usr/sbin/networksetup -removenetworkservice "${service}"
done

exit 0