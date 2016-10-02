#!/bin/bash

#######################################################################
# proof of concept contigency plan for devices becoming unmanaged
# tested against JSS version 9.3 and OS X 10.9.2 client
# use at own risk, no warranty or support provided
#######################################################################

# by tlark
# version 0.1

# first we run a policy to make sure the device can communicate with the JSS and is managed
# the policy should be a manual triggered event, and just a file in the run command box

# put varialbes below:

# JSS URL

JSSurl=''

# URL of quickadd pkg in case we need to re-enroll, alternatively this could be cached locally already

quickaddURL=''

# path where you want the quickadd package to be dowloaded to

downloadPath=/private/var/downloads

# name of package, i.e. quickadd

PKGname=QuickAdd_CasperAdmin.pkg

# valid invitation code from JSS QuickAdd

invCode=''

## Set global variables

LOGPATH='/var/log/iRobot'
LOGFILE=$LOGPATH/autoenroll-$(date +%Y%m%d-%H%M).log
VERSION=10.11.4
STARTTIME=date

## Setup logging
mkdir $LOGPATH
echo $STARTIME > $LOGFILE
set -xv; exec 1>> $LOGFILE 2>&1


####################
#
# start functions
#
####################

getQuickAdd() {

	# make sure download path exists

	if [[ ! -d ${downloadPath} ]]
		then mkdir -p ${downloadPath}
    fi

cd ${downloadPath} && curl -k -O "${quickaddURL}"

if [[ -e ${downloadPath}/${PKGname} ]]
    then echo "Looks good"
    else echo "failed to download package"
    touch /private/var/clientfailed.txt
    exit 1
	fi
}

jamfManageClient() {

if [[ -e /private/var/client/pkg/${PKGname} ]]
	then installer -allowUntrusted -pkg /private/var/client/pkg/${PKGname} -target /
    else installer -allowUntrusted -pkg "${downloadPath}/${PKGname}" -target /
fi

# create the conf file for enrollment
jamf createConf -url ${JSSurl}

# now enroll the device so we can have proper certificate based communication
jamf enroll -invitation ${invCode}

rm /private/var/downloads/*
rm /private/var/client/receipts/*
}


jamfCheck() {

jamf policy -event testClient

sleep 5 # give it 5 seconds to do it's thing

if [[ -e /private/var/client/receipts/clientresult.txt ]]
  then echo "policy created file, we are good"
       echo "removing dummy receipt for next run"
       rm /private/var/client/receipts/clientresult.txt
       exit 0
  else echo "policy failed, could not run"
       touch /private/var/client/receipts/clientfailed.txt
fi

}

# now execute commands and functions

jamfCheck

# make sure we have a quickadd pkg present

if [[ -e /private/var/client/pkg/${PKGname} ]]
	then echo "we have a pkg"
    else getQuickAdd
fi

if [[ -e /private/var/client/receipts/clientfailed.txt ]]
	then jamfManageClient
fi

exit 0
