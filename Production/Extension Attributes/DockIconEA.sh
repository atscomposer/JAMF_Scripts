#!/bin/bash

IFS=$'\n'
parent_dir=`/usr/bin/dirname "$0"`
dockutil_exe_path="/usr/local/dockutil/dockutil"
loggedInUser=`ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

i="$(defaults read /Users/$loggedInUser/Library/Preferences/com.apple.dock persistent-apps | grep tile-type | awk '/file-tile/ {print NR}')"
    	# loop through the list of positions
    	for  j in `echo "$i"`
    	do
  		filePath=`/usr/libexec/PlistBuddy -c "Print persistent-apps:$[$j-1]:tile-data:file-data:_CFURLString" /Users/$loggedInUser/Library/Preferences/com.apple.dock.plist`		
		if [[ $filePath =~ "Self%20Service.app" ]]; then
        	selfservice=Yes
        fi
        done
        
    if [[ $selfservice = "Yes" ]]; then
    	echo "<result>Yes</result>"
    else
    	echo "<result>No</result>"
    fi
        


