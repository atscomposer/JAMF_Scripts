#!/bin/bash
# closeApps.command
# Author: Joel Bruner

###################
# Functions
###################
function sendlog
{
#system.log
logger "[$$] $@"
#seperate update log
echo "$@"
}

function runOSA
{
osascript 2>/dev/null<<-EOF
with timeout of 1000000 seconds
$@
end timeout
EOF
}

function getProcs
{
for (( i=0; i<${#myArgs[@]}; i++ )); do
runOSA 'tell application "System Events" to get name of every process whose name contains "'${myArgs[$i]}'"'
done
}

function checkSystem
{
#sendlog "Running $scriptName, parameters: \"$1\"";
# check to make sure we are running as root
if [ ! $(id -u) -eq 0 ]; then sendlog "Must be run as root, exiting." exit 1;
fi

#is this running in a policy?
#if so the argument list will need to be shifted 3
echo "$(ps auxww)" | grep -q "[j]amf policy -id"
result=$?

[ $result -eq 0 ] && jamfScript=1
[ $result -eq 1 ] && jamfScript=0
}

#for troubleshooting
function printProcArray
{
for (( i=0; i<${#procArray[@]}; i++ )); do
sendlog Process $i: ${procArray[$i]}
done
}

function parseArgs
{
#Shift forward 3 so to skip first 3 JAMF arguments
if [ $jamfScript -eq 1 ]; then
shift 3
fi

if [ -z "$1" ]; then
sendlog "No arguments, exiting"
exit 1;
fi

#make myArgs array
for arg in ${@}; do myArgs[${i:=0}]=$arg
let i++;
done
}

function makeProcList
{
#make array of processes running
procArray=( $(for proc in $(getProcs); do echo $proc | sed 's/^ //g' | perl -p -e 's/, /\n/g'; done) )

procString=""; ##reset procString
#make display formatted string with commas
for (( i=0; i<${#procArray[@]}; i++ )); do 
if [ -z "$procString" ]; then procString=${procArray[$i]} 
	else procString="$procString, ${procArray[$i]}" 
fi
done

procList='' ## reset procList
#make applescript formatted list to loop through
#format is {"This", "That", "Other"}, do quotes fist curly braces at end
for (( i=0; i<${#procArray[@]}; i++ )); do 
if [ -z "$procList" ]; then procList=\"${procArray[$i]}\" 
	else procList="$procList, \"${procArray[$i]}\"" 
fi
done

#add curly braces
procList="{ $procList }"

#sendlog procList
}

function alertUser
{
#if you don't single quote you must escape double quotes for osascript
runOSA 'tell app "Finder" to activate'
runOSA 'tell app "Finder" to display dialog "Please Close the following applications:\n'"${procString}"'\n\nClick Close Apps and Install to close the listed apps (otherwise Quit manually)\n\nPlease save all unsaved work prior to clicking Close Apps and Install\n" buttons {"Close Apps and Install", "Cancel"} with icon 0'
}

function waitForClose
{
makeProcList;

if [ ${#procArray[@]} -ne 0 ]; then 
while [ ${#procArray[@]} -ne 0 ]; do
#run Applescript to alert user 
myResult=$(alertUser); 
sendlog MY RESULT: $myResult
if [ "$myResult" == "button returned:OK" ]; then
	makeProcList; 
fi
if [ "$myResult" == "button returned:Close Apps and Install" ]; then 
	printProcArray; quitAll; makeProcList; 
fi
if [ -z "$myResult" ]; then 
	Cancel; exit 0; 
fi 
done
fi
}

function quitAll
{
osascript <<-EOF
repeat with proc in $procList 
try 
	tell application proc to quit 
on error
	do shell script "killall " & quoted form of proc
end try 
end repeat
EOF

#sometimes too fast for an app to close, so have it wait
sleep 2
}

function Cancel
{
#if we are not in JAMF so just exit non zero
if [ $jamfScript -eq 0 ]; then
exit 0
fi

#else we are in JAMF

#get parent policy string
policyNames=$(ps auxww | grep "/usr/sbin/[j]amf policy -id")
policyPIDS=$(ps auxww | grep "/usr/sbin/[j]amf policy -id" | awk {'print $2'})

if [ -z "$policyPIDS" ]; then
sendlog "Could not find processes to kill $policyNames"
exit 1
fi

sendlog "Cancelled/Timeout, killing $policyPIDS"
kill -9 $policyPIDS
}

###################
#CocoaDialog Variables
###################

CD_APP="/Library/iRobot/CocoaDialog.app"
CD="$CD_APP/Contents/MacOS/CocoaDialog"

###################
# MAIN
###################
checkSystem;

#applescript uses commas between commands
IFS=$',\n\r\t'
#get the arguments of the apps we want to close
parseArgs ${@};
#process contain spaces so don't use those in IFS
IFS=$'\n\r\t'

#creates myArgs array
waitForClose;

exit 0
