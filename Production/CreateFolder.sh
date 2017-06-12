#!/bin/sh -x

###############################################################################
#
# Name: CreateFolder.sh
# Version: 1.0
# Create Date:  22 May 2017
# Last Modified: 23 May 2017
#
# Author:  Adam Shuttleworth
# Purpose: This script creates folder defined by Jamf Pro script variable $4
#
###############################################################################

# Hardcoded value for testing
#folder="/Users/svc_forescout/.ssh"

## Set $needed_free_space variable either through hardcoded value or JAMF pre-set variable
if [[ "$folder" == "" ]] && [[ "$4" != "" ]]; then
    folder="$4"
elif [[ "$folder" == "" ]] && [[ "$4" == "" ]]; then
    echo "A Custom trigger was not specified in parameter 4. Script cannot execute. Exiting..."
    exit 1
fi

if [[ ! -d $folder ]]; then
	echo ".ssh folder does not exist and will be created."
	mkdir "$folder"
	chown svc_forescout "$folder"
else
	echo ".ssh folder exists in SVC_Forescout user home folder."
fi

exit 0