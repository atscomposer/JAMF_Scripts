#!/bin/bash

cdPath="/Library/iRobot/cocoaDialog.app/Contents/MacOS/cocoaDialog"

customTrigger="main_office2016"

#if [[ "$customTrigger" == "" ]] && [[ "$4" != "" ]]; then
#    customTrigger="$4"
#elif [[ "$customTrigger" == "" ]] && [[ "$4" == "" ]]; then
#    echo "A Custom trigger was not specified in parameter 4. Script cannot execute. Exiting..."
#    exit 1
#fi

appCheckList=(
"Microsoft Outlook"
"Microsoft Word"
"Microsoft Excel"
"Microsoft PowerPoint"
)

function checkForRunningApps ()
{

runningAppsList=()

x=0
while read appname; do
    if [[ $(ps axc | grep "$appname") != "" ]]; then
        runningAppsList+=("• ${appCheckList[$x]}")
    fi
    let x=$((x+1))
done < <(printf '%s\n' "${appCheckList[@]}")


if [[ "${runningAppsList[@]}" != "" ]]; then

appListText="The following applications are running and must be closed before continuing with this installation.

$(printf '%s\n' "${runningAppsList[@]}")

Close the above applications, then click Continue. If you need to Cancel this installation, click Cancel."

    promptUser=$("$cdPath" msgbox \
        --title "iRobot IT" \
        --text "Applications must be closed" \
        --informative-text "$appListText" \
        --button1 "Continue" \
        --button2 "Cancel" \
        --icon info \
        --width 400)

    if [ "$promptUser" == "1" ]; then
        checkForRunningApps
    else
        exit 0
    fi
else
    echo "No applications running to be shut down. Continuing..."

    installInProgressText="The Microsoft Office 2016 installation is now in progress. Please be patient as it takes some time to finish.

Please do not try to open any Office applications until you see a final \"Microsoft Office 2016 Installed\" message at the end. You can dismiss this window and the installation will continue."

    "$cdPath" msgbox \
    --title "iRobot IT" \
    --text "Installation in progress" \
    --informative-text "$installInProgressText" \
    --icon info \
    --button1 "   OK   " \
    --timeout 300 \
    --timeout-format " " \
    --width 450 \
    --quiet &

    ## Call the install policy by manual trigger
    #jamf policy -trigger "$customTrigger"
fi

}

## Get the free disk space on the internal drive
freeDiskSpace=$(df -H / | awk '{getline; print $4}' | sed 's/[A-Z]//')

## If free space is too low, alert user and exit
if [[ "$freeDiskSpace" -lt 12 ]]; then
    "$cdPath" msgbox \
    --title "iRobot IT" \
    --text "Not enough free disk space" \
    --informative-text "Sorry. Your Mac only has $freeDiskSpace GBs of free disk space. This installation requires at least 12 GBs free to continue. Please make the additional space available required for the installation, and then try again." \
    --button1 "   OK   " \
    --icon caution \
    --width 400 \
    --quiet

    exit 0
else
    ## Otherwise, move on to checking for running Office apps
    checkForRunningApps
fi