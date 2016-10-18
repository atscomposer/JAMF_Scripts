#!/bin/sh -x
## postflight
##
## Not supported for flat packages.

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3

cd /Users
for AUSER in *
do
    if [ "$AUSER" != *\(Deleted\) -a "$AUSER" != "Shared" -a "$AUSER" != "Guest" ]; then
    	timestamp="20161014"
    	wordtimestamp=$(stat -f "%Sm" -t "%Y%m%d" "/Users/$AUSER/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Templates.localized/iRobot.dotm")
    	PPTtimestamp=$(stat -f "%Sm" -t "%Y%m%d" "/Users/$AUSER/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Templates.localized/iRobot.dotm")
        if [ ! $timestamp -eq $wordtimestamp ]; then
        	cp /Library/iRobot/Resources/Templates/iRobot.dotm /Users/$AUSER/Library/Group\ Containers/UBF8T346G9.Office/User\ Content.localized/Templates.localized/
        	chown "$AUSER" /Users/$AUSER/Library/Group\ Containers/UBF8T346G9.Office/User\ Content.localized/Templates.localized/iRobot.dotm
		fi
        if [ ! $timestamp -eq $PPTtimestamp ]; then
        	cp /Library/iRobot/Resources/Templates/iRobot.potx /Users/$AUSER/Library/Group\ Containers/UBF8T346G9.Office/User\ Content.localized/Templates.localized/
        	chown "$AUSER" /Users/$AUSER/Library/Group\ Containers/UBF8T346G9.Office/User\ Content.localized/Templates.localized/iRobot.potx
		fi
    fi
done

exit 0




exit 0		## Success
exit 1		## Failure