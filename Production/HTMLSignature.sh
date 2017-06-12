#!/bin/bash

###############################################################################
#
# Name: HTML Email Signature Creator (HTMLSignature.sh)
# Version: 1.0
# Create Date:  30 January 2017
# Last Modified: 12 June 2017
#
# Author:  Adam Shuttleworth
# Purpose: Script to create HTML Email Signature in Outlook in the following format:
#
#########################################
#										#
#	FIRSTNAME LASTNAME					#
#	JOBTITLE							#	
#	DEPARTMENT							#	
#										#
#	{CompanyName}						#
#	LOCATION							#
#	t: PHONENUM							#
#	EMAIL								#
#										#
# 	Company Logo						#
#										#
#	Follow us on social media:			#
#	{Links to social media channels}	#
#										#
#########################################
#
# Requirements: !. Up-to-date "User and Location" on JAMF Pro Server for each computer.
#					The script uses this information to gather the necessary data for the following fields in the signature using the JAMF API:
#						FIRTNAME derived from realname api attribute
#						LASTNAME derived from realname api attribute
#						JOBTITLE derived from position api attribute
#						DEPARTMENT derived from department api attribute
#						LOCATION derived by using the building api attribute and based on the value adding the appropriate full address
#						PHONENUM derived from phone_number api attribute
#						EMAIL derived from email_address api attribute
#				2. Company logo to be distributed to client machines to same path as companyLogo variable.
# JAMF Pro Setup:
# 	1. Create Package with Company Logo at same path as companyLogo variable in DMG through JAMF Composer
# 	2. Create JAMF Policy
# 		- Frequency: Ongoing
#		- Package: CompanyLogo DMG created in step 1
#		- Script: This script set at After Priority with the following Parameters:
#			Parm 4: API User Name (requires Read Only privileges to all Computer Objects)
#			Parm 5: API User Password
#			Parm 6: Jamf URL (i.e. - https://company.jamfcloud.com:443)
#			Parm 7: Path where Company Logo has been distributed in each computer
#		- Self Service 
#			- Turned on
#			- Button Name "Create"
#			- Outlook Icon
###############################################################################

## Set global variables

## Set the API Username here if you want it hardcoded
apiUser=""		
## Set the API Password here if you want it hardcoded
apiPass=""
## Set the JSS URL here if you want it hardcoded		
jamfURL=""		
COMPNAME=$( scutil --get ComputerName )
## Set the companyLogo path here if you want it hardcoded
companyLogo="/Library/iRobot/Logos/iRobot_Logo_RGB_Web.png"

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
if [[ "$companyLogo" == "" ]] && [[ "$7" != "" ]]; then
	companyLogo="$7"
fi

jamfEAURL="${jamfURL}/JSSResource/computers/name/${COMPNAME}/subset/Location" ## Set up the JSS Computer-->User Location URL
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
	## Make sure to remove any trailing / in the passed parameter for the JSS URL
	jamfURL=$( echo "$jamfURL" | sed 's/\/$//' )
fi
  
api=$( curl -sfku "${apiUser}":"${apiPass}" "${jamfEAURL}" )

USERNAME=`stat -f%Su /dev/console`

FIRSTNAME=$( echo $api | /usr/bin/awk -F'<realname>|</realname>' '{print $2}' | cut -d' ' -f2 )
LASTNAME=$( echo $api | /usr/bin/awk -F'<realname>|</realname>' '{print $2}' | cut -d',' -f1 )
JOBTITLE=$( echo $api | /usr/bin/awk -F'<position>|</position>' '{print $2}' )
DEPARTMENT=$( echo $api | /usr/bin/awk -F'<department>|</department>' '{print $2}' )
OFFICE=$( echo $api | /usr/bin/awk -F'<building>|</building>' '{print $2}' )
PHONENUM=$( echo $api | /usr/bin/awk -F'<phone_number>|</phone_number>' '{print $2}' )
EMAIL=$( echo $api | /usr/bin/awk -F'<email_address>|</email_address>' '{print $2}' )

if [[ $OFFICE = "US - Massachusetts" ]]; then
	LOCATION="
8 Crosby Drive<br/>
Bedford, MA 01730"
fi

if [[ $OFFICE = "US - California" ]]; then
	LOCATION="
177 E Colorado Blvd.<br/>
Suite 400<br/>
Pasadena, CA 91105"
fi

if [[ $OFFICE = "Hong Kong" ]]; then
	LOCATION="
06,11/F, Exchange Tower<br/>
33 Wang Chiu Road<br/>
Kowloon Bay, Kowloon, HK"
fi

if [[ $OFFICE = "China - Guangzhou" ]]; then
	LOCATION="
A1305 Center Plaza<br/>
163 Linhe Xi Road, Tianhe District<br/>
Guangzhou, China"
fi

if [[ $OFFICE = "China - Shanghai" ]]; then
	LOCATION="
Two ICC<br/>
2814-16 Middle HuaiHai Road, XuHui District<br/>
Shanghai, China 200031"
fi

if [[ $OFFICE = "United Kingdom" ]]; then
	LOCATION="
10 Greycoat Place<br/>
Victoria<br/>
SW1P 1SB<br/>
London, United Kingdom"
fi

if [[ $OFFICE = "Japan" ]]; then
	LOCATION="
3F, 2-26, Shimomiyabi-cho,<br/>
Shinjuku-ku, Tokyo 162-0822 Japan"
fi

HTML="<span style=font-family:'Arial';font-size:12.0pt><b>$FIRSTNAME $LASTNAME</b><br/>
$JOBTITLE<br/>
$DEPARTMENT<br/>
<br/>
iRobot<br/>
$LOCATION<br/>
t: $PHONENUM<br/>
<a href='mailto:$EMAIL'>$EMAIL</a><br/>
<br/>
<img src="${companyLogo}"><br/>
<br/>
Follow us on social media:<br/>
<a href='https://www.facebook.com/iRobot/'><u>Facebook</u></a> | <a href='https://twitter.com/iRobot'><u>Twitter</u></a> | <a href='https://www.instagram.com/irobot/'><u>Instagram</u></a> | <a href='https://www.youtube.com/user/irobot'><u>YouTube</u></a>
</span>"

osascript <<EOD
tell application "Microsoft Outlook" to activate
tell application "Microsoft Outlook"
    make new signature with properties {name:"$FIRSTNAME $LASTNAME", content:"$HTML"}
end tell
EOD

#tell application "Microsoft Outlook" to activate
#tell application "System Events"
 #   click menu item "Preferences..." of menu 1 of menu bar item "Outlook" of menu bar 1 of application process "Outlook"
  #  click item 1 of (buttons of window "Outlook Preferences" of application process "Outlook" whose description is "Signatures")
   # select last item of (rows of table 1 of scroll area 2 of window "Signatures" of application process "Outlook")
#end tell
#EOD