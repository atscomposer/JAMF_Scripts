#!/bin/sh

#   this script was written to remove vpn network services for osx
#   author:     Andrew Thomson
#   date:       05-26-13

#   make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#   set path to preference file
theFilePath="/Library/Preferences/SystemConfiguration/preferences.plist"

#   make a backup copy of the preference file
if [ -e $theFilePath ]; then
	/bin/cp -f $theFilePath $theFilePath.bak
else
    echo Preference file not found.
    exit 1
fi

#   find network services keys -- assumes consistent file structure
theServiceKeys=`/usr/bin/xpath $theFilePath  "/plist/dict/dict[1]/key" | awk '{gsub("<key>","")};1' | awk '{gsub("</key>","\n")};1'`

#   enumerate keys to identify VPN network services
for theService in $theServiceKeys
do
    theDefinedName=`/usr/libexec/PlistBuddy -c "Print :NetworkServices:$theService:UserDefinedName" $theFilePath`

    #   does this key contain a VPN service?
    isVPN=`echo $theDefinedName | grep -q VPN; echo $?`

    #   if VPN service is found, delete corrosponding key 
	if [ $isVPN == 0 ]; then
    	/usr/libexec/PlistBuddy -c "Delete :NetworkServices:$theService" $theFilePath
      	/usr/libexec/PlistBuddy -c Save $theFilePath
    fi
done