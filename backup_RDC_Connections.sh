#!/bin/bash

# Copy MS RDC Preferences and Data to OneDrive
cp ~/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences/com.microsoft.rdc.mac.plist /Users/ashuttleworth/OneDrive\ -\ iRobot\ Corporation/MS_RDP_Backup
cp -R ~/Library/Containers/com.microsoft.rdc.mac/Data/Library/Application\ Support/Microsoft\ Remote\ Desktop /Users/ashuttleworth/OneDrive\ -\ iRobot\ Corporation/MS_RDP_Backup

# Copy Backed Up Data to new directory from One Drive Directory
#cp ~/OneDrive\ -\ iRobot\ Corporation/MS_RDP_Backup/com.microsoft.rdc.mac.plist ~/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences
#cp -R ~/OneDrive\ -\ iRobot\ Corporation/MS_RDP_Backup/Microsoft\ Remote\ Desktop  ~/Library/Containers/com.microsoft.rdc.mac/Data/Library/Application\ Support

#sudo killall cfprefsd