#!/bin/sh -x

###############################################################################
#
# Name: AddVPNtoMenuBar.sh
# Version: 2.0
# Create Date:  3 May 2017
# Last Modified:
#
# Author:  Adam Shuttleworth
# Purpose:  This script adds VPN option to user menu bar.
#
###############################################################################

###################### Get current user ########################

CurrentUser=`ls -l /dev/console | cut -d " " -f4`

############# Run the Command as the currently logged in user ################
check=`su -l "${CurrentUser}" -c 'defaults read com.apple.systemuiserver menuExtras | grep "/System/Library/CoreServices/Menu Extras/vpn.menu"'`
check2=`su -l "${CurrentUser}" -c 'defaults read com.apple.systemuiserver menuExtras | grep "/System/Library/CoreServices/Menu Extras/VPN.menu"'`

if [[ -z "$check" ]] && [[ -z "$check2" ]]; then
	su -l "${CurrentUser}" -c 'defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/vpn.menu" && killall SystemUIServer -HUP'
fi
exit 0
