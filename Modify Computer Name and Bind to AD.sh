#!/bin/bash
# Author: Adam Shuttleworth
# Created: 2016-06-15
# Modified: 2016-06-22

################################################################################
# FUNCTIONS

# Function to ensure admin privileges
RunAsRoot() {
##  Pass in the full path to the executable as $1
if [[ "$(/usr/bin/id -u)" != "0" ]] ; then
echo "This application must be run with administrative privileges."
osascript -e "do shell script \"${1}\" with administrator privileges"
exit 0
fi
}

# Test if CocoaDialog is not installed. If not installed, it will be installed.
if [ ! -d "/Library/iRobot/CocoaDialog.app" ]; then
jamf policy -trigger installCocoa
fi
################################################################################
## User Variables

#Test if coputer is bound to AD
check4AD=`/usr/bin/dscl localhost -list . | grep "Active Directory"`

# Set the path to the cocoaDialog application.c
# Will be used to display prompts.
CD="/Library/iRobot/CocoaDialog.app/Contents/MacOS/CocoaDialog"

## More variables - No need to edit
rv=($($CD standard-inputbox --title "Computer Name" --no-cancel --float --no-newline --informative-text "Enter your iRobot Asset Tag Numer (e.g. - 6100)"))
ADCOMPUTERNAME='irbt-'${rv[1]}

################################################################################

# Clear previous commands from Terminal
clear

# Execute runAsRoot function to ensure administrative privileges
RunAsRoot "${0}"

# Check for cocoaDialog dependency and exit if not found
if [[ ! -f "${CD}" ]]; then
echo "Required dependency not found: ${CD}"
exit 1
fi

## Change Computer Name with User input
scutil --set HostName $ADCOMPUTERNAME
sleep 1s
scutil --set LocalHostName $ADCOMPUTERNAME
sleep 1s
scutil --set ComputerName $ADCOMPUTERNAME
sleep 1s
dscacheutil -flushcache
sleep 5s

# If the machine is not bound to AD, then there's no purpose going any further.
if [[ "${check4AD}" != "Active Directory" ]]; then
if ping -c 2 -o hq-dcw-02.wardrobe.irobot.com; then
jamf policy -id 13
else
rv=`$CD ok-msgbox --text "ERROR Binding Computer to AD!" \
--informative-text "(Please ensure the computer is connected to iRobot-Secure Wifi or iRobot wired network)" \
--no-newline --float --no-cancel`
if [ "$rv" == "1" ]; then
	if ping -c 2 -o hq-dcw-02.wardrobe.irobot.com; then
		jamf policy -id 13
	else
		rv=`$CD ok-msgbox --text "ERROR Binding Computer to AD!" \
		--informative-text "(Please ensure the computer is connected to iRobot-Secure Wifi or iRobot wired network)" \
		--no-newline --float --no-cancel`
		if [ "$rv" == "1" ]; then
			if ping -c 2 -o hq-dcw-03.wardrobe.irobot.com; then
				jamf policy -id 13
			else	
				exit 1		
			fi
		fi	
	fi				
fi
fi
fi
