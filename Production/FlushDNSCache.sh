#!/bin/bash

###############################################################################
#
# Name: FlushDNSCache.sh
# Version: 1.0
# Create Date:  01 February 2017
# Last Modified:
#
# Author:  Adam Shuttleworth
# Purpose: This script flushes DNS cache with the appropriate command based on OS version.  
# NOTE: Works with OS versions 10.5-10.12. Code needs to be modified for subsequent OS versions.
#
###############################################################################

# Location of cocoaDialog binary
# cocoaDialog provides a "gui" for the repair tool. It should be installed at
# the path below. NOTE: This must point to the actual binary inside the app bundle
ccd="/Library/iRobot/cocoaDialog.app/Contents/MacOS/cocoaDialog"

# Make sure cocoaDialog is installed; if not, attempt to fix it via policy
# If the binary is not found, we call a Casper policy with a custom trigger "installcocoaDialog"
# to attempt to install it.
if [[ ! -f "${ccd}" ]]; then
     echo "DNS Cache Flush: Attempting to install cocoaDialog via policy"
     /usr/sbin/jamf policy -forceNoRecon -event installCocoa
     if [[ ! -f "${ccd}" ]]; then
          echo "DNS Cache Flush: Unable to install cocoaDialog, so we need to quit"
          exit 1
     else
          echo "DNS Cache Flush: cocoaDialog is now installed"
     fi
fi

# Get the current OS version to serve as an example
THIS_OS=$(sw_vers -productVersion)

case $THIS_OS in
    10.[5-6]*)
        dscacheutil -flushdnscache
        ;;
    10.[7-9]*)
        killall -HUP mDNSResponder
        ;;
    10.10.[0-3]*)
        discoveryutil mdnsflushcache
        ;;
    10.10.4)
        killall -HUP mDNSResponder
        ;;
    10.1[1-2]*)
        killall -HUP mDNSResponder
        ;;
    *)
		Text="OS Version has not been specified or DNS Flush command has not been set for this particular OS (${THIS_OS})."
      	   promptUser=$("$cdPath" msgbox \
        	--title "iRobot IT" \
        	--text "Error" \
        	--informative-text "$Text" \
        	--button1 "OK" \
        	--icon caution \
        	--width 400)
	;;   
	esac
	
if [ "$promptUser" == "1" ]; then
    exit 1
fi

exit 0