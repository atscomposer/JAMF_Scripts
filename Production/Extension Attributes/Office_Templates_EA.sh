#!/bin/bash -x

user=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

pptTemp="/Users/$user/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Templates.localized/iRobot.potx"
wordTemp="/Users/$user/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Templates.localized/iRobot.dotm"
    
    if [ ! -f "$pptTemp" ] || [ ! -f "$wordTemp" ]; then
       echo "<result>No</result>"
    else
        echo "<result>Yes</result>"
    fi

exit 0