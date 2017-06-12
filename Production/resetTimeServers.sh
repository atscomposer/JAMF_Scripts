#!/bin/bash

###############################################################################
#
# Name: resetTimeServers.sh
# Version: 1.0
# Create Date:  01 March 2017
# Last Modified:
#
# Author: Adam Shuttleworth
# Purpose:  This script resets the time servers to use:
#           Primary: iRobot Time Server 
#           Secondary: iRobot Time Server 
#			Tertiary: Apple Time Server
#
###############################################################################
# Hardcoded variables
#primary="ntp.irobot.com"
#secondary="time.irobot.com"
#tertiary="time.apple.com"

# Check if time servers are 
if [[ "$primary" == "" ]] && [[ "$4" != "" ]]; then
    primary="$4"
fi
if [[ "$secondary" == "" ]] && [[ "$5" != "" ]]; then
    secondary="$5"
fi
if [[ "$tertiary" == "" ]] && [[ "$6" != "" ]]; then
    tertiary="$6"
fi

# Primary Time server
TimeServer1=$primary
#echo $TimeServer1

# Secondary Time server
TimeServer2=$secondary
#echo $TimeServer2

# Tertiary Time Server for iRobot Macs, used outside of iRobot's network
TimeServer3=$tertiary
#echo $TimeServer3

# Activate the primary time server. Set the primary network server with systemsetup
sudo /usr/sbin/systemsetup -setnetworktimeserver $TimeServer1

# Add the secondary time server
echo "server $TimeServer2" >> /etc/ntp.conf

# Add the tertiary time server
echo "server $TimeServer3" >> /etc/ntp.conf

# Enables the OS X to set its clock using the network time server
sudo /usr/sbin/systemsetup -setusingnetworktime on
