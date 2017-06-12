#!/bin/sh

###############################################################################
#
# Name: Uninstall_Lync_2011.sh
# Version: 1.0
# Create Date:  31 October 2016
# Last Modified:
#
# Author:  Adam Shuttleworth
# Purpose:  Script to associate the last loggedin user as the asset owner in JAMF
#
###############################################################################

#Script for uninstalling the Microsoft Lync 2011 for Mac

#Attempt to kill Lync processes
/usr/bin/killall 'Microsoft Lync'

#Remove the varios Lync installed bits and pieces
/bin/rm -rf /Applications/Microsoft\ Lync.app

#Tell the system to forget that Lync was ever installed
LYNCRECEIPTS=$( /usr/sbin/pkgutil --pkgs=com.microsoft.lync.* )
for ARECEIPT in $LYNCRECEIPTS
do
	/usr/sbin/pkgutil --forget $ARECEIPT
done

#Remove all Lync system artifacts
rm -R ~/Library/Preferences/ByHost/MicrosoftLyncRegistrationDB.*
rm -r ~/Library/Preferences/com.microsoft.Lync.plist
rm -R ~/Library/Logs/Microsoft-Lync-*
rm -R ~/Library/Logs/Microsoft-Lync.log
rm -R ~/Documents/Microsoft\ User\ Data/Microsoft\ Lync\ Data
rm -R ~/Documents/Microsoft\ User\ Data/Microsoft\ Lync\ History
rm -R ~/Library/Caches/com.microsoft.Lync

exit 0
