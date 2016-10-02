#!/bin/bash

# auto re-enroll script
# this will download the JAMF binary from a web app, and attempt to re-enroll the device
# this requires that the launchd is in place to run this script at a set interval
# this script also requires a test policy that can be triggered manually that will touch a file on the client's local file system
# most likely this should all be bundled together at a post image install, and/or enrollment triggered policy
# this is a proof of concept, no warranty given, use at own risk


# by tlark
# version 0.2
# changed the test JSS URL function to use curl and look for 401 as a HTTP response tyring to access a device object via the API

#### define user variables below:

# the URL of your JSS, if you are behind a load balancer you can use the URL and do not put a slash on the end
# example = https://myjss.company.com:8443
jssURL=''

# an inviation code from a quickadd package generated from Recon.app
invitationCode=''


#### start variables defined by the code and user variables

# location of the JAMF binary on any web app
jamfBinary="${jssURL}/bin/jamf.gz"


#### start functions do not edit below this line ####

folderCheck() {
	folderList=( /private/var/client /private/var/client/receipts /private/var/client/downloads /private/var/client/pkg )

	for folder in ${folderList[@]} ; do

		if [[ ! -d ${folder} ]]
			then mkdir -p ${folder}
		    else echo "folder exists"
		fi
	done
}

jamfCheck() {

jamf policy -event testClient

sleep 5 # give it 5 seconds to do it's thing

if [[ -e /private/var/client/receipts/clientresult.txt ]]
  then echo "policy created file, we are good"
       echo "removing dummy receipt for next run"
       rm /private/var/client/receipts/clientresult.txt
       rm /private/var/client/receipts/clientfailed.txt
       exit 0
  else echo "policy failed, could not run"
       touch /private/var/client/receipts/clientfailed.txt
fi

}

jssConnectionTest() {

	jssTest=$(curl -k -I ${jssURL}/JSSResource/computers/id/1 | awk '/HTTP/ { print $2}')
	
	if [[ ${jssTest} == '401' ]]
	then echo "we can connect to the JSS" 
  else echo "JSS is not reachable...exiting"
    	 exit 0
  fi
}

downloadBinary() {

    # get the current binary from the JSS
	curl -k --silent --retry 5 -o /private/var/client/downloads/jamf.gz ${jamfBinary}

	if [[ ! -f /private/var/client/downloads/jamf.gz ]]
		then echo "download failed, exiting..."
		     touch /private/var/client/receipts/clientfailed.txt
		     exit 1
	fi

}

jamfEnroll() {

	if [[ -f /private/var/client/downloads/jamf.gz ]]
		then echo "looks good"
    else echo "failed to curl down binary"
         touch /private/var/client/receipts/clientfailed.txt
         exit 0
  fi

    # if it exists, unzip it
    gzip -d /private/var/client/downloads/jamf.gz

    # now test it 
    testBinary=$(/private/var/client/downloads/jamf help 2>&1 > /dev/null ; echo $?)
      if [[ ${testBinary} == '0' ]]
      	then echo "test good, we can move it"
        else echo "something went wrong, marking failed"
        	 touch /private/var/client/receipts/clientfailed.txt
      fi

      # now back up the old JAMF.keychain for those just incase moments

      mv /Library/Application\ Support/JAMF/JAMF.keychain /private/var/client/JAMF.keychain.old 

      # now we need to move the binary, apply proper permissions/ownership into place and enroll the client
        mv /private/var/client/downloads/jamf /usr/sbin/jamf
        chown root:wheel /usr/sbin/jamf
        chmod +rx /usr/sbin/jamf

        jamf createConf -k -url ${jssURL}

        jamf enroll -invitation ${invitationCode} -noRecon

}

folderCheck
jssConnectionTest
jamfCheck

if [[ -e /private/var/client/receipts/clientfailed.txt ]]
	then downloadBinary
	     jamfEnroll
	else echo "no failure found, exiting"
		 exit 0
fi

exit 0
