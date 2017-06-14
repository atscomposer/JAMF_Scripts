#!/bin/bash

###############################################################################
#
# Name: RemoveCitrixReceiver.sh
# Version: 1.0
# Create Date: 
# Last Modified: 
#
# Author:  Wagner Mateo
# Purpose:  Script uninstalls all managed printers from print server(s)
#
###############################################################################

## Variables
CurrentUser=`ls -l /dev/console | cut -d " " -f4`
process="Citrix Receiver"
apputil="/Applications/Utilities/"

## Script
processrunning=$( ps axc | grep "${process}" )
if [ "$processrunning" != "" ]; then 
	echo "$process found running" 
	appdir=$(mdfind -onlyin /Applications/ "kMDItemKind == 'Application' && kMDItemDisplayName == '$process'") 
	echo "App directory is: ${appdir}" 
	echo "Stopping process: $process" 
	killall "${process}" 
	sleep 5
fi

rm -rf /Applications/Citrix\ Receiver.app
rm -rf /Users/$(CurrentUser)/Applications/
rm -rf /Library/Internet plug-ins/CitrixICAClientPlugIn.plugin
rm -rf /Library/LaunchAgents/com.citrix.AuthManager_Mac.plist
rm -rf /Library/LaunchAgents/com.citrix.ServiceRecords.plist
rm -rf /Users/$(CurrentUser)/Applications/
rm -rf /Users/$(CurrentUser)/Library/Application\ Support/Citrix\ Receiver
rm -rf /Users/$(CurrentUser)/Applications/Internet plug-ins/CitrixICAClientPlugIn.plugin
rm -rf /Users/$(CurrentUser)/Library/Application\ Support/Citrix\ Receiver/Config
rm -rf /Users/$(CurrentUser)/Library/Application\ Support/Citrix\ Receiver/CitrixID
rm -rf /Users/$(CurrentUser)/Library/Application\ Support/Citrix\ Receiver/Module
rm -rf /Users/$(CurrentUser)/Preferences/com.citrix.ReceiverFTU.AccountRecords.plist
rm -rf /Users/$(CurrentUser)/Preferences/com.citrix.receiver.nomas.plist
rm -rf /Users/$(CurrentUser)/Preferences/com.citrix.receiver.nomas.plist.lockfile
rm -rf /private/var/db/receipts
rm -rf /private/var/db/receipts/com.citrix.ICAClient.bom
rm -rf /private/var/db/receipts/com.citrix.ICAClient.plist
rm -rf /Users/$(CurrentUser)/Library/Application/Citrix/FollowMeData 
rm -rf /Users/$(CurrentUser)/Library/Application\ Support/ShareFile
rm -rf /Library/PreferencePanes/FMDSysPrefPane.prefPane
rm -rf /private/var/db/receipts/com.citrix.ShareFile.installer.plist
rm -rf /private/var/db/receipts/com.citrix.ShareFile.installer.bom
rm -rf /Users/*/ShareFile
rm -rf /private/var/db/receipts/com.citrix.ShareFile.installer.plist
rm -rf /private/var/db/receipts/com.citrix.ShareFile.installer.bom

exit 0