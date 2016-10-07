#!/bin/sh
## postflight
##
## Not supported for flat packages.

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3

cd /Users
for AUSER in /Users/
do
    if [ "$AUSER" != *\(Deleted\) -a "$AUSER" != "Shared" -a "$AUSER" != "Guest" ] ; then
        cp /Library/iRobot/Resources/Templates/iRobot.potx /Users/$AUSER/Library/Group\ Containers/UBF8T346G9.Office/User\ Content.localized/Templates.localized/
        cp /Library/iRobot/Resources/Templates/iRobot.dotm /Users/$AUSER/Library/Group\ Containers/UBF8T346G9.Office/User\ Content.localized/Templates.localized/
        chown "$AUSER" /Users/$AUSER/Library/Group\ Containers/UBF8T346G9.Office/User\ Content.localized/Templates.localized/iRobot.potx
        chown "$AUSER" /Users/$AUSER/Library/Group\ Containers/UBF8T346G9.Office/User\ Content.localized/Templates.localized/iRobot.dotm
    fi
done

exit 0




exit 0		## Success
exit 1		## Failure