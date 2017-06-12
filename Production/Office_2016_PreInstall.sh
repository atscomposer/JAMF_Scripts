#!/bin/sh

###############################################################################
#
# Name: Office_2016_PostInstall.sh
# Version: 1.0
# Create Date:  01 February 2017
# Last Modified: 12 June 2017
#
# Author:  Adam Shuttleworth
# Purpose: This script runs before Office 2016 installation and 
#  		   finds removes Microsoft Office 2011 application completely
#
###############################################################################

if ! [[ $COMMAND_LINE_INSTALL && $COMMAND_LINE_INSTALL != 0 ]]
then
	register_trusted_cmd="/usr/bin/sudo -u $USER /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -R -f -trusted"
	application="/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/Microsoft AU Daemon.app"

	if /bin/test -d "$application"
	then
		$register_trusted_cmd "$application"
	fi
fi
	osascript -e 'tell application "Microsoft Database Daemon" to quit'
	osascript -e 'tell application "Microsoft AU Daemon" to quit'
	osascript -e 'tell application "Office365Service" to quit'
	rm -R '/Applications/Microsoft Communicator.app/'
	rm -R '/Applications/Microsoft Messenger.app/'
	rm -R '/Applications/Microsoft Office 2011/'
	rm -R '/Applications/Remote Desktop Connection.app/'
find -f '/Library/Application Support/Microsoft/' ! -name 'scep' -type d -exec rm -R;
	rm -R /Library/Automator/*Excel*
	rm -R /Library/Automator/*Office*
	rm -R /Library/Automator/*Outlook*
	rm -R /Library/Automator/*PowerPoint*
	rm -R /Library/Automator/*Word*
	rm -R /Library/Automator/*Workbook*
	rm -R '/Library/Automator/Get Parent Presentations of Slides.action'
	rm -R '/Library/Automator/Set Document Settings.action'
	rm -R /Library/Fonts/Microsoft/
	mv '/Library/Fonts Disabled/Arial Bold Italic.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Arial Bold.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Arial Italic.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Arial.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Brush Script.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Times New Roman Bold Italic.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Times New Roman Bold.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Times New Roman Italic.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Times New Roman.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Verdana Bold Italic.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Verdana Bold.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Verdana Italic.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Verdana.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Wingdings 2.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Wingdings 3.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Wingdings.ttf' /Library/Fonts
	rm -R /Library/Internet\ Plug-Ins/SharePoint*
	rm -R /Library/LaunchDaemons/com.microsoft.*
	rm -R /Library/Preferences/com.microsoft.*
	rm -R /Library/PrivilegedHelperTools/com.microsoft.*
	OFFICERECEIPTS=$(pkgutil --pkgs=com.microsoft.office.*)
	for ARECEIPT in $OFFICERECEIPTS
	do
		pkgutil --forget $ARECEIPT
	done
open -a "System Center 2012 Endpoint Protection"

exit 0
