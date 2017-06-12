#!/bin/bash -x

###############################################################################
#
# Name: Uninstall Sophos Enterprise.sh
# Version: 1.0
# Create Date:  20 January 2017
# Last Modified:
#
# Author:  Adam Shuttleworth
# Purpose:  Script to remove Sophos Enterprise
#
###############################################################################
# CocoaDialog File Location
CD="/Library/iRobot/cocoaDialog.app/Contents/MacOS/CocoaDialog"

#Uninstall Sophos Enterprise
if [ -f /Library/Application\ Support/Sophos/saas/Installer.app/Contents/MacOS/tools/InstallationDeployer ]
then
check="$(/Library/Application\ Support/Sophos/saas/Installer.app/Contents/MacOS/tools/InstallationDeployer --force_remove 2>&1 >/dev/null)"
else
	echo "Sophos is not installed" 
fi

echo $check

if [[ "$check" = *"Tamper protection check failed. Exiting."* ]]
then
	rv=`$CD ok-msgbox --no-newline \
		--title "Sophos Enterprise Uninstall" \
	--text "Error Uninstalling Sophos Enterprise" \
	--informative-text "Tamper Protection on.  Please contact Information Security for assistance at infosec@irobot.com." \
	--no-cancel --icon caution`
elif [[ "$check" = "The removal was successful." ]]
then
touch /Library/Receipts/sophosUninstall.plist
	rv=`$CD ok-msgbox --no-newline \
		--title "Sophos Enterprise Uninstall" \
	    --text "Success: Uninstalling Sophos Enterprise" \
	    --informative-text "Uninstalling Sophos Enterprise was successful" \
	   --no-cancel --icon application`
fi
exit 0
