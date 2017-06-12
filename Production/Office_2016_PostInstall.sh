#!/bin/sh

###############################################################################
#
# Name: Office_2016_PostInstall.sh
# Version: 1.0
# Create Date:  01 February 2017
# Last Modified: 12 June 2017
#
# Author:  Adam Shuttleworth
# Purpose: This script runs after Office 2016 installation and 
#  		   finds all Microsoft Office 2011 dock icons and replaces with Office 2016 icons
#
# Required: dockutil.exe from Microsoft Office 2016 installer.  Package file and distribute with script.
#
#			Follow these instructions to obtain:
#			
#			Expand the application package provided from Microsoft (portal.office.com) (i.e. - Microsoft_Office_2016_15.34.17051500_Installer.pkg:
# 				pkgutil  --expand <location of .pkg> <location to save extracted folder/files>
#
#			Find the dockutil.exe file here:
#				./Office15_all_licensing.pkg/Scripts
#
###############################################################################

# change permissions and load Office LicensingV2 Helper
/bin/chmod u+w /Library/LaunchDaemons/com.microsoft.office.licensingV2.helper.plist
/bin/launchctl load /Library/LaunchDaemons/com.microsoft.office.licensingV2.helper.plist

# enable for loops over items with spaces in their name
IFS=$'\n'
parent_dir=`/usr/bin/dirname "$0"`
dockutil_exe_path="$parent_dir/dockutil"

# loop through all user folders in /Users
for dirname in `ls /Users`
do
# only work with actual folders
if [ -d "/Users/$dirname" ]; then
# only work with end user folders ignoring the local admin account and the Shared Folder
if [ "$dirname" != "irbt" ] && [ "$dirname" != "administrator" ] && [ "$dirname" != "Shared" ] && [ "$dirname" != "Guest" ]; then
#create a backup copy of the com.apple.dock.plist
ditto /Users/$dirname/Library/Preferences/com.apple.dock.plist /Users/$dirname/Library/Preferences/com.apple.dock.plist.office2011
fi
i="$(defaults read /Users/$dirname/Library/Preferences/com.apple.dock persistent-apps | grep tile-type | awk '/file-tile/ {print NR}')"
# loop through the list of positions
for  j in `echo "$i"`
do
# get the file path for the current position
filePath=`/usr/libexec/PlistBuddy -c "Print persistent-apps:$[$j-1]:tile-data:file-data:_CFURLString" /Users/$dirname/Library/Preferences/com.apple.dock.plist`
if [[ $filePath =~ "Microsoft%20Office%202011/Microsoft%20Word.app" ]]; then
/usr/bin/sudo -u $USER "$dockutil_exe_path" --add /Applications/Microsoft\ Word.app --replacing 'Microsoft Word' --no-restart
/bin/sleep 3
fi

# get the file path for the current position
filePath=`/usr/libexec/PlistBuddy -c "Print persistent-apps:$[$j-1]:tile-data:file-data:_CFURLString" /Users/$dirname/Library/Preferences/com.apple.dock.plist`
if [[ $filePath =~ "Microsoft%20Office%202011/Microsoft%20Outlook.app" ]]; then
	    /usr/bin/sudo -u $USER "$dockutil_exe_path" --add /Applications/Microsoft\ Outlook.app --replacing 'Microsoft Outlook' --no-restart
/bin/sleep 3
fi

# get the file path for the current position
filePath=`/usr/libexec/PlistBuddy -c "Print persistent-apps:$[$j-1]:tile-data:file-data:_CFURLString" /Users/$dirname/Library/Preferences/com.apple.dock.plist`
if [[ $filePath =~ "Microsoft%20Office%202011/Microsoft%20Excel.app" ]]; then
	    /usr/bin/sudo -u $USER "$dockutil_exe_path" --add /Applications/Microsoft\ Excel.app --replacing 'Microsoft Excel' --no-restart
/bin/sleep 3
fi

# get the file path for the current position
filePath=`/usr/libexec/PlistBuddy -c "Print persistent-apps:$[$j-1]:tile-data:file-data:_CFURLString" /Users/$dirname/Library/Preferences/com.apple.dock.plist`
if [[ $filePath =~ "Microsoft%20Office%202011/Microsoft%20PowerPoint.app" ]]; then
/usr/bin/sudo -u $USER "$dockutil_exe_path" --add /Applications/Microsoft\ PowerPoint.app --replacing 'Microsoft PowerPoint' --no-restart
/bin/sleep 3
fi
done
fi
done

# Delete the Dock Icon cache files for every user to ensure the new icons show
rm -rf /private/var/folders/*/*/-Caches-/com.apple.dock.iconcache

# Uncomment the following command if this is run while a user is logged in.  It will restart the dock to refresh the icons.
killall Dock
exit 0
