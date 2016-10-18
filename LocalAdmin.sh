#!/bin/bash

###############################################################################
#
# Name: LocalAdmin.sh
# Version: 1.0
# Create Date:  18 October 2016
# Last Modified: 18 October 2016
#
# Author:  Adam Shuttleworth
# Purpose: Script to get assigned user in JSS and elevate the account to local admin
#		and remove any other local admin
###############################################################################

## Set global variables

LOGPATH='/var/log/iRobot'
LOGFILE=$LOGPATH/LocalAdmin-$(date +%Y%m%d-%H%M).log
VERSION=10.12
STARTTIME=date
COMPNAME=$( scutil --get ComputerName )

apiUser=""		## Set the API Username here if you want it hardcoded
apiPass=""		## Set the API Password here if you want it hardcoded
jamfURL=""		## Set the JSS URL here if you want it hardcoded
jamfEAURL="${jssURL}/JSSResource/computers/name/${COMPNAME}/subset/Location" ## Set up the JSS Computer-->User Location URL

#mkdir $LOGPATH
#echo $STARTIME > $LOGFILE
#set -xv; exec 1>> $LOGFILE 2>&1

## Check to see if the script was passed any script parameters from Casper
if [[ "$apiUser" == "" ]] && [[ "$4" != "" ]]; then
	apiUser="$4"
fi

if [[ "$apiPass" == "" ]] && [[ "$5" != "" ]]; then
	apiPass="$5"
fi

if [[ "$jamfURL" == "" ]] && [[ "$6" != "" ]]; then
	jamfURL="$6"
fi

## Finally, make sure we got at least an apiUser & apiPass variable, else we exit
if [[ -z "$apiUser" ]] || [[ -z "$apiPass" ]]; then
	echo "API Username = $apiUser\nAPI Password = $apiPass"
	echo "One of the required variables was not passed to the script. Exiting..."
	exit 1
fi

## If no server address was passed to the script, get it from the Mac's com.jamfsoftware.jamf.plist
if [[ -z "$jamfURL" ]]; then
	jamfURL=$( /usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url 2> /dev/null | sed 's/\/$//' )
	if [[ -z "$jamfURL" ]]; then
		echo "Jamf URL = $jamfURL"
		echo "Oops! We couldn't get the Jamf URL from this Mac, and none was passed to the script"
		exit 1
	else
		echo "Jamf URL = $jamfURL"
	fi
else
	## Make sure to remove any trailing / in the passed parameter for the JSS URL
	jamfURL=$( echo "$jamfURL" | sed 's/\/$//' )
fi
  
api=$( curl -sfku "${apiUser}":"${apiPass}" "${jamfEAURL}" )
username=$( echo $api | /usr/bin/awk -F'<username>|</username>' '{print $2}' )

loggedInUID=$( id -u "$3" )
loggedinUserName=$( user=`ls -l /dev/console | awk '/ / { print $3 }'`)

if [[ "$username" == "$loggedinUserName" ]]; then
    echo "User $3 is the primary user of this device."
	if [[ "$loggedInUID" -ge 1000 ]]; then
		echo "User $3 is an Active Directory account. Checking admin status..."
		isAdmin=$( /usr/sbin/dseditgroup -o checkmember -m $3 admin 1> /dev/null; echo $? )
		if [[ "$isAdmin" -gt 0 ]]; then
			echo "$3 is not an admin. Promoting to local admin..."
			/usr/sbin/dseditgroup -o edit -a $3 -t user admin
			if [[ "$?" == 0 ]]; then
				echo "$3" > /private/var/ADlocalAdminSet
				exit 0
			else
				echo "Operation not successful"
				exit 1
			fi
		else
			echo "$3 is already an admin. Exiting..."
			exit 0
		fi
	else
		echo "$3 is not an Active Directory account. Exiting..."
	fi
else
	echo "$3 is not the primary user for this device. Exiting..."
	exit 0
fi

#exec 3>&-
#/bin/rm -f /tmp/hpipe