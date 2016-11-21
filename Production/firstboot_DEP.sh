#!/bin/sh

###############################################################################
#
# Name: firstboot_DEP.sh
# Version: 1.0
# Create Date:  28 June 2016
# Last Modified: 14 July 2016
#
# Author:  Adam Shuttleworth
# Purpose:  first boot script to run as part of imaging process to configure
# systems.
#
###############################################################################

## Set global variables

LOGPATH='/var/log/iRobot'
JSSURL='https://irbt.jamfcloud.com'
JSSCONTACTTIMEOUT=120
LOGFILE=$LOGPATH/deployment-$(date +%Y%m%d-%H%M).log
VERSION=10.11.4
STARTTIME=date

## Setup logging
mkdir $LOGPATH
echo $STARTIME > $LOGFILE
set -xv; exec 1>> $LOGFILE 2>&1

# Wait for Enrollment to complete
sleep 5s

# check for jamf binary
/bin/echo "Checking for JAMF binary"
/bin/date

if [[ "$jamf_binary" == "" ]] && [[ -e "/usr/sbin/jamf" ]] && [[ ! -e "/usr/local/bin/jamf" ]]; then
jamf_binary="/usr/sbin/jamf"
elif [[ "$jamf_binary" == "" ]] && [[ ! -e "/usr/sbin/jamf" ]] && [[ -e "/usr/local/bin/jamf" ]]; then
jamf_binary="/usr/local/bin/jamf"
elif [[ "$jamf_binary" == "" ]] && [[ -e "/usr/sbin/jamf" ]] && [[ -e "/usr/local/bin/jamf" ]]; then
jamf_binary="/usr/local/bin/jamf"
fi

#Initial JSS Invetory Update
${jamf_binary} recon


## Cocoa Dialog
/bin/echo "Installing Cocoa Dialog"
/bin/date
${jamf_binary} policy -id 84 -forceNoRecon

# Set cocoaDialog location
CD="/Library/iRobot/cocoaDialog.app/Contents/MacOS/cocoaDialog"

# Make pipe
/bin/rm -f /tmp/hpipe
/usr/bin/mkfifo /tmp/hpipe
/bin/sleep 0.2

# Background job to take pipe input
"$CD" progressbar --title "iRobot Imaging Process" --text "Executing Imaging Policies" --float --stoppable < /tmp/hpipe &

# Link file descriptor
exec 3<> /tmp/hpipe

######################################################################################
######################################################################################
#
# 		Tasks that do not require access to the JSS
#
######################################################################################

####
# grab the OS version and Model, we'll need it later
####

modelName=`system_profiler SPHardwareDataType | awk -F': ' '/Model Name/{print $NF}'`

echo $4
echo $5

######################################################################################
# Dummy package with image date and computer Model
# - this can be used with an ExtensionAttribute to tell us when the machine was last imaged
######################################################################################
/bin/echo "5 Creating imaging receipt..." >&3
/bin/date
TODAY=`date +"%Y-%m-%d"`
touch /Library/Application\ Support/JAMF/Receipts/$modelName_Imaged_$TODAY.pkg

###############################################################################
#
#   S Y S T E M   P R E F E R E N C E S
#
# This section deals with system preference tweaks
#
###############################################################################
/bin/echo "10 Setting system preferences" >&3
/bin/date

#
# add our hidden bin path to $PATH

/bin/echo "Adding PATH" 
/bin/date
/bin/echo "/private/var/inte/bin" >> /etc/paths

# Disable Time Machine's pop-up message whenever an external drive is plugged in

defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

###########
# TIME
###########

/bin/echo "15 Setting Time Servers" >&3
# Primary Time server
TimeServer1=ntp.irobot.com

# Secondary Time server
TimeServer2=time.irobot.com

# Tertiary Time Server for iRobot Macs, used outside of iRobot's network
TimeServer3=time.apple.com

# Activate the primary time server. Set the primary network server with systemsetup
/usr/sbin/systemsetup -setnetworktimeserver $TimeServer1

# Add the secondary time server
echo "server $TimeServer2" >> /etc/ntp.conf

# Add the tertiary time server
echo "server $TimeServer3" >> /etc/ntp.conf

# Enables the OS X to set its clock using the network time server
/usr/sbin/systemsetup -setusingnetworktime on

### Enable Location Services to set time based on location

/bin/launchctl unload /System/Library/LaunchDaemons/com.apple.locationd.plist
uuid=`ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/{print $4}'`
/usr/bin/defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd.$uuid \
LocationServicesEnabled -int 1
/usr/sbin/chown -R _locationd:_locationd /var/db/locationd
/bin/launchctl load /System/Library/LaunchDaemons/com.apple.locationd.plist

# set time zone automatically using current location
/usr/bin/defaults write /Library/Preferences/com.apple.timezone.auto Active -bool true

# Set the login window to name and password

defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

###########
# SSH
###########
# enable remote log in, ssh
/bin/echo "20 Setting ssh" >&3
/bin/date
/usr/sbin/systemsetup -setremotelogin on

###########
#  AFP
###########

# Turn off DS_Store file creation on network volumes
/bin/echo "25 Turning off DS_Store" >&3
/bin/date
defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.desktopservices \
DSDontWriteNetworkStores true

### universal Access - enable access for assistive devices
## http://hints.macworld.com/article.php?story=20060203225241914
/bin/echo "30 Enabling assistive devices" >&3
/bin/date

/bin/echo -n 'a' | /usr/bin/sudo /usr/bin/tee /private/var/db/.AccessibilityAPIEnabled > /dev/null 2>&1
/usr/bin/sudo /bin/chmod 444 /private/var/db/.AccessibilityAPIEnabled

### auto brightness adjustment off
/bin/echo "35 Disabling auto brightness" >&3
/bin/date
/usr/bin/defaults write com.apple.BezelServices 'dAuto' -bool false

###  Expanded print dialog by default
# <http://hints.macworld.com/article.php?story=20071109163914940>
#
/bin/echo "40 Expanding print dialog by default" >&3
/bin/date
# expand the print window
defaults write /Library/Preferences/.GlobalPreferences PMPrintingExpandedStateForPrint2 -bool TRUE

###########
#  Misc
###########

##Kill Dock Fixup
rm -R /Library/Preferences/com.apple.dockfixup.plist

################################################
#  Disable AppleID Popo-up Prompt with new login
################################################

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
sw_vers=$(sw_vers -productVersion)

# Checks first to see if the Mac is running 10.7.0 or higher. 
# If so, the script checks the system default user template
# for the presence of the Library/Preferences directory.
#
# If the directory is not found, it is created and then the
# iCloud pop-up settings are set to be disabled.

if [[ ${osvers} -ge 7 ]]; then

for USER_TEMPLATE in "/System/Library/User Template"/*
do
defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
done

# Checks first to see if the Mac is running 10.7.0 or higher.
# If so, the script checks the existing user folders in /Users
# for the presence of the Library/Preferences directory.
#
# If the directory is not found, it is created and then the
# iCloud pop-up settings are set to be disabled.

for USER_HOME in /Users/*
do
USER_UID=`basename "${USER_HOME}"`
if [ ! "${USER_UID}" = "Shared" ] 
then 
if [ ! -d "${USER_HOME}"/Library/Preferences ]
then
mkdir -p "${USER_HOME}"/Library/Preferences
chown "${USER_UID}" "${USER_HOME}"/Library
chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
fi
if [ -d "${USER_HOME}"/Library/Preferences ]
then
defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant.plist
fi
fi
done
fi

##########################################
# /etc/authorization changes
##########################################

security authorizationdb write system.preferences allow
security authorizationdb write system.preferences.datetime allow
security authorizationdb write system.preferences.printing allow
security authorizationdb write system.preferences.energysaver allow
security authorizationdb write system.preferences.network allow
security authorizationdb write system.services.systemconfiguration.network allow

# rename computer so it will fall into scope for first boot policies
/bin/echo "50 Renaming Computer for Imaging" >&3
sernum=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformSerialNumber/{print $4}')
scutil --set ComputerName "NEW-${sernum}-DEP"
scutil --set HostName "NEW-${sernum}-DEP"
scutil --set LocalHostName "NEW-${sernum}-DEP"

mkdir /Library/Application\ Support/JAMF/Receipts
touch /Library/Application\ Support/JAMF/Receipts/firstboot.pkg
/bin/echo "55 Updating JSS Inventory" >&3
${jamf_binary} recon

## System Center Endpoint Protection
/bin/echo "60 Installing System Center Endpoint Protection" >&3
/bin/date
${jamf_binary} policy -id 6 -forceNoRecon

## Sophos Enterprise (Turn on when we switch to Sophos)
#bin/echo "60 Installing Sophos Enterprise" >&3
#/bin/date
#${jamf_binary} policy -id 6 -forceNoRecon

## Falcon Sensor
/bin/echo "65 Installing Falcon Sensor" >&3
/bin/date
${jamf_binary} policy -id 5 -forceNoRecon

## Office 2016
/bin/echo "70 Installing Office 2016" >&3
/bin/date
${jamf_binary} policy -id 85 -forceNoRecon

## Lync 2011
/bin/echo "75 Installing Lync 2011" >&3
/bin/date
${jamf_binary} policy -id 43 -forceNoRecon

## Lync Launch Agent and Script
/bin/echo "80 Installing Lync Launch Agent and Script" >&3
/bin/date
${jamf_binary} policy -id 47 -forceNoRecon

launchctl load -w ~/Library/LaunchAgents/com.iRobot.LyncSetup.plist

## Printer Drivers
/bin/echo "85 Installing Printer Drivers" >&3
/bin/date
${jamf_binary} policy -id 17 -forceNoRecon

## Set EFI Password
#/bin/echo "SetEFI Password"
#/bin/date
#${jamf_binary} policy -id 3 -forceNoRecon

/bin/echo "90 Installing Apple Software Updates (if exist)" >&3
/bin/date
softwareupdate --clear-catalog
softwareupdate -iav

killall jamfHelper
# shutdown -r now

## UnJoin Computer from AD
/bin/echo "95 Unbinding Computer from AD" >&3
check4AD=`/usr/bin/dscl localhost -list . | grep "Active Directory"`
username="user"
password="nopassword"

if [[ "${check4AD}" = "Active Directory" ]]; then
echo "Unbinding the computer from Active Directory..."
/usr/sbin/dsconfigad -r -u $username -p $password -force
echo "Restarting Directory Services..."
/usr/bin/killall DirectoryService
fi

sleep 5s

## Modify Computer Name and Bind to AD
/bin/echo "100 Modifying Computer Name and Binding to AD" >&3
/bin/date
${jamf_binary} policy -id 42 -forceNoRecon

# Let processes catch up
/usr/bin/wait

# Turn off progress bar by closing file descriptor 3 and removing the named pipe
echo "Closing progress bar."
exec 3>&-
/bin/rm -f /tmp/hpipe

exit 0
