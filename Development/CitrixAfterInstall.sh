#!/bin/sh
################################################################################
# Author: Adam Shuttleworth
# Modified: Adam Shuttleworth
# Modified: 2016-10-25
#
# This script utilizes CocoaDialog.app to notify users what Citrix groups they
# are in and provides an avenue to request access to other applications
#
#
################################################################################# Variables
#

# Test if CocoaDialog is not installed. If not installed, it will be installed.
if [ ! -d "/Library/iRobot/CocoaDialog.app" ]; then
	jamf policy -trigger installCocoa
	echo "Installing CocoaDialog"
fi

# Set the path to the cocoaDialog application.
# Will be used to display prompts.
CD="/Library/iRobot/CocoaDialog.app/Contents/MacOS/CocoaDialog"

domain=$( echo show com.apple.opendirectoryd.ActiveDirectory | scutil | grep DomainNameFlat | awk '{print $3}' )
if [ $? -ne 0 ]
then
    echo "Failed to get domain name, exiting script"
    exit 1
fi
if [ -z $domain ]
then
     echo "Failed to get domain name, exiting script"
     exit 1
fi
echo "AD Domain name: $domain "
userName=$( id -u -nr )
if [ $? -ne 0 ]
then
     echo "Failed to get user name, exiting script"
     exit 1
fi

echo "User name: $userName"

# Display that the user has just installed Citrix Receiver
  rv=( $("${CD}" msgbox --title "Citrix Receiver Configuration" \
    --text "Citrix Receiver has been installed" \
    --informative-text "To configure which apps are available to you, please click Next." \
    --float \
    --button1 "Next" \
    --button2 "Close" \
    --icon user) )

if [ "$rv" == "1" ]; then
    # Display which Citrix AD Groups they are associated
	$currentApps=$( dscl /Active\ Directory/${domain}/All\ Domains read /Users/${userName} dsAttrTypeNative:memberOf | grep 'XenApp' | awk -F"OU" '{ print $1 }' | sed -e 's/CN=//g;s/,$//g;1d' )
	
	#'BEGIN { FS = "," } ; {print $1}' | awk 'BEGIN { FS = "=" } ; {print $2}' )
  	# Generate User Account Selection dialog to get 'old username'
  	acctReturn=( $("${CD}" msgbox --title "Current Citrix Apps" \
    	--text "You currently have access to these Citrix apps."
    	--informative-text "${currentApps}. To see available applications, please click Next." \
    	--float \
    	--button1 "Next" \
    	--button2 "Finish" \
    	--icon user) )
elif [ "$rv" == "2" ]; then
    exit 0
fi

# Display that available groups and allow them to request to be 
# added to a group via email to servicedesk@irobot.com

