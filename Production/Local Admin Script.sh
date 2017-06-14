#!/bin/bash

###############################################################################
#
# Name: LocalAdmin.sh
# Version: 1.0
# Create Date:  18 October 2016
# Last Modified: 14 June 2017
#
# Author:  Adam Shuttleworth
# Purpose: Script to get assigned user in JAMF Pro Server and elevate their domain account to local admin
#		and remove any other domain accounts that are local admins.  Meant to be used with 
#
# Requirements: 
#	1. JAMF Pro
#	2. LDAP configured in JAMF Pro server (System Settings-->LDAP Servers)
# 	3. Computer must be bound to LDAP domain (i.e. - AD) and users login as directory account
#	4. User associated with each JAMF Pro computer object in computer's "User and Location" section
#	4. JAMF Pro API user with read-only permissions to computer objects
#
###############################################################################

## GLOBAL VARIABLES
# Logging
LOGPATH='/var/log/iRobot'
LOGFILE=$LOGPATH/LocalAdmin-$(date +%Y%m%d-%H%M).log
STARTTIME=date

mkdir $LOGPATH
echo $STARTIME > $LOGFILE
set -xv; exec 1>> $LOGFILE 2>&1

# Computer Name
COMPNAME=$( scutil --get ComputerName | sed -e 's/ /%20/g' ) 

# API User, if hardcoded is needed
apiUser=""		## Set the API Username here if you want it hardcoded
apiPass=""		## Set the API Password here if you want it hardcoded
jamfURL="" 	## Set the JSS URL here if you want it hardcoded

# Check to see if the script was passed any script parameters from JAMF Pro
if [[ "$apiUser" == "" ]] && [[ "$4" != "" ]]; then
	apiUser="$4"
fi

if [[ "$apiPass" == "" ]] && [[ "$5" != "" ]]; then
	apiPass="$5"
fi

if [[ "$jamfURL" == "" ]] && [[ "$6" != "" ]]; then
	jamfURL="$6"
fi

## SCRIPT
# JAMF Pro API Info
jamfEAURL="${jamfURL}/JSSResource/computers/name/${COMPNAME}/subset/Location" ## Set up the JAMF Pro Computer-->User Location URL
jamfEAURL=$( echo "$jamfEAURL" | sed -e 's/ /%20/g' ) ## Make sure to replace spaces in URL to %20 for correct API lookup later in the script
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
	## Make sure to remove any trailing / in the passed parameter for the JAMF Pro URL
	jamfURL=$( echo "$jamfURL" | sed 's/\/$//' )
fi

## Get computer object through JAMF Pro API and username associated with computer object 
api=$( curl -sfku "${apiUser}":"${apiPass}" "${jamfEAURL}" )
username=$( echo $api | /usr/bin/awk -F'<username>|</username>' '{print $2}' )

## Get logged in user
loggedInUID=$( id -u "$3" )
loggedinUserName=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

## Check if logged in user is LDAP user and is assigned user to JAMF Pro computer object
## If both are true, elevate user to local admin. All other users are made standard userss
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
		exit 0
	fi
else
	echo "$3 is not the primary user for this device. Exiting..."
	isAdmin=$( /usr/sbin/dseditgroup -o checkmember -m $3 admin 1> /dev/null; echo $? )
	if [[ "$isAdmin" -eq 0 ]] && [[ "$loggedInUID" -ge 1000 ]]; then
	    echo "$3 will be removed from Administrators group."
	    /usr/sbin/dseditgroup -o edit -d $3 -t user admin 
	else
		echo "$3 is correctly a standard user. Exiting..."
		exit 0
	fi
	exit 0
fi

exec 3>&-
/bin/rm -f /tmp/hpipe
