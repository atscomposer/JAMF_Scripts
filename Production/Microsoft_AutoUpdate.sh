#!/bin/bash

###############################################################################
#
# Name: Micorosft_AUotUpdate.sh
# Version: 1.0
# Create Date:  20 January 2017
# Last Modified: 14 June 2017
#
# Author:  Adam Shuttleworth
# Purpose:  This script sets the Microsoft AutoUpdate setting to AutomaticCheck
#
###############################################################################

user=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
plist="/Users/$user/Library/Preferences/com.microsoft.autoupdate2.plist"

if [[ -f $plist ]]; then
	su - $user -c "defaults write /Users/$user/Library/Preferences/com.microsoft.autoupdate2.plist HowToCheck 'AutomaticCheck'"
	# Check if plist attribute HowToCheck has been set correctly
	check=$(defaults read /Users/$user/Library/Preferences/com.microsoft.autoupdate2.plist HowToCheck)
	case $check in
		AutomaticCheck)
		echo "Microsoft AutoUpdate has been configured to Automatically Check"
		;;
		*)
		echo "ERROR: Microsoft AutoUpdate has not been configured successfully"
		;;
	esac
else
	echo "Microsoft AutoUpdate is not installed"
fi

exit 0