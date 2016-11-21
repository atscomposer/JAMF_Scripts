#!/bin/sh -x 

################################################################################
# Author: Adam Shuttleworth
# Modified: Adam Shuttleworth
# Modified: 2016-10-18
#
# This script utilizes CocoaDialog.app to change mobile Mac OS X user account's
# username and information.  Mostly for scenarios where a person changes their name.
#
#
################################################################################

# Test if CocoaDialog is not installed. If not installed, it will be installed.
if [ ! -d "/Library/iRobot/CocoaDialog.app" ]; then
	jamf policy -trigger installCocoa
	echo "Installing CocoaDialog"
fi

# Set the path to the cocoaDialog application.
# Will be used to display prompts.
CD="/Library/iRobot/CocoaDialog.app/Contents/MacOS/CocoaDialog"

# Set an Active Directory username that is not likely to be removed.
# Will be used to check AD connectivity
lookupAccount="svc_jamf_bind"

################################################################################
# Other Variables (Should not need to modify)
#

Version=1.0
listUsers=( $(/usr/bin/dscl . list /Users UniqueID | grep -v '_sophos' | awk '$2 > 1000 { print $1; }') )
listUsersHome=( $(cd "/Users/" && ls | grep -v 'Guest' | grep -v 'Shared' | grep -v '(Deleted)') )
check4AD=$(/usr/bin/dscl localhost -list . | grep "Active Directory")
osvers=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $2}')

################################################################################

# Check for cocoaDialog dependency and exit if not found
if [[ ! -f "${CD}" ]]; then
  echo "Required dependency not found: ${CD}"
  exit 1
fi

# If the machine is not bound to AD, then there's no purpose going any further.
#if [[ "${check4AD}" != "Active Directory" ]]; then
  #echo "This machine is not bound to Active Directory. We will bind to AD now."
  #jamf policy -trigger bindToAD
#fi

# Lookup a domain account and check exit code for error
/usr/bin/id -u "${lookupAccount}"
if [[ $? -ne 0 ]]; then
  	rv=$("${CD}" ok-msgbox --title "AD Connection Error" \
    	--text "AD Connection Error"\
    	--informative-text "It doesn't look like this Mac is communicating with AD correctly. Ensure you are on iRobot Secure WiFi, office LAN, or VPN. Exiting the script." \
    	--float \
    	--no-cancel \
    	--icon stop)
    exit 1
fi

# Loop until 'Finished' button is selected
until [[ "${acctReturn[0]}" == "2" ]]; do

  # Generate User Account Selection dialog to get 'old username'
  acctReturn=( $("${CD}" dropdown --title "New Username Selection" \
    --text "Please choose the new username." \
    --float \
    --items ${listUsers[@]} \
    --button1 "Continue" \
    --button2 "Finish" \
    --icon user) )

  if [[ "${acctReturn[0]}" == "1" ]]; then
    user="${listUsers[${acctReturn[1]}]}"
    echo "Selected '${user}' to migrate."
  elif [[ "${acctReturn[0]}" == "2" ]]; then
    echo "Exiting from 'User Account Selection' dialog."
    exit 0
  fi

  if [[ ! -n "${user}" ]]; then
    die "'${user}' not found."
  elif [[ $(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }') == "${user}" ]]; then
  	rv=$("${CD}" ok-msgbox --title "Login as Another Admin" \
    	--text "Login as Another Admin"\
    	--informative-text "${user} is logged in. Please log this user out and log in as another admin." \
    	--float \
    	--no-cancel \
    	--icon stop)
    exit 1
  fi

# Get AD username
  rv=( $("${CD}" dropdown --title "Old Username Selection" \
    --text "Please choose the old username." \
    --float \
    --items ${listUsersHome[@]} \
    --button1 "Continue" \
    --button2 "Finish" \
    --icon user) )

  if [[ "${rv[0]}" == "1" ]]; then
    netname="${listUsersHome[${rv[1]}]}"
    echo "Entered '${netname}' as old username."
  elif [[ "${rv[0]}" == "2" ]]; then
    echo "Exiting from 'Old Username Selection' dialog."
    exit 0
  fi
  
  # Determine location of the users home folder
  userHome="$(/usr/bin/dscl . read /Users/"${user}" NFSHomeDirectory | /usr/bin/cut -c 19-)"

  # Check if there's a home folder there already, if there is, exit before we wipe it
#  if [[ ! -f /Users/"${netname}" ]]; then
#  	rv=$("${CD}" ok-msgbox --title "Home Directory Does Not Exists" \
#    	--text "Home Directory Does Not Exists"\
#    	--informative-text "Oops, there is no home folder there for ${netname}. Please log in as ${netname}. Exiting..." \
#    	--float \
#    	--no-cancel \s
#    	--icon stop)
#    exit 1
 #  else
    ditto /Users/"${netname}" /Users/"${user}"
    echo "Home directory for '${user}' is now located at '/Users/${user}'."

    /usr/sbin/chown -hR "${user}" /Users/"${user}"
    echo "Permissions for '/Users/${user}' are now set properly."

#    /System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount -n "${netname}"
#    echo "Account for ${netname} has been created on this computer"
 # fi

# Display success dialog
  rv=$("${CD}" ok-msgbox --title "Successful Change" \
    --text "Successful Change" \
    --informative-text "Successfully changed username. Please go to Active Directory and change the user's Account username prior to the user logging in." \
    --float \
    --no-cancel \
    --icon notice)

done

