#!/bin/sh

###############################################################################
#
# Name: Remove Old Account (RemoveOldAccount.sh)
# Version: 1.0
# Create Date:  06 February 2017
# Last Modified:
#
# Author:  Adam Shuttleworth
# Purpose: This script removes an old user account and is used prior to adding the latest fore scout account.
#
###############################################################################

## Set global variables

## Set the API Username here if you want it hardcoded
#account=""		

## Check to see if the script was passed any script parameters from JAMF Pro
if [[ "$account" == "" ]] && [[ "$4" != "" ]]; then
	account="$4"
fi

if [[ $(dscl . list /Users) =~ "${account}" ]]; then 
    # Remove user
    dscl localhost delete Local/Default/Users/svc_forescout
    sudo rm -rf /Users/svc_forescout
    echo "User has been removed"
else 
    echo "User has not been created on this computer."
fi

