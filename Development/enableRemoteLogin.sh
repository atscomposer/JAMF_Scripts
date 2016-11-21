#!/bin/sh

# Enable ARD, Remote Management, and Remote Login (SSH) 
# 1. Removes Administrators Group from Remote login
# 2 & 3. Creates xxxxxxxxx Membership
# 4 & 5. Adds xxxxxxxxx User to Remotelogin then activates.

sudo dseditgroup -o edit -a admin -t group com.apple.access_ssh
sudo dscl . append /Groups/com.apple.access_ssh user irbt
sudo dscl . append /Groups/com.apple.access_ssh GroupMembership irbt
#sudo dscl . append /Groups/com.apple.access_ssh groupmembers `dscl . read /Users/xxxxxxxxx GeneratedUID | cut -d " " -f 2`
sudo systemsetup -setremotelogin on#!/bin/sh

################################################################################

# Author: Adam Shuttleworth
# Created: 2016-06-29
# Modified: 2016-06-29
# Name: LocalAdminScript

################################################################################

##  Promote the first (and ONLY first) Active Directory user that logs in to local admin status

loggedInUID=$( id -u "$3" )

if [[ "$loggedInUID" -ge 1000 ]]; then
    echo "User $3 is an Active Directory account. Checking admin status..."
    isAdmin=$( /usr/sbin/dseditgroup -o checkmember -m $3 admin 1> /dev/null; echo $? )
    if [[ "$isAdmin" -gt 0 ]]; then
        echo "$3 is not an admin. Promoting to local admin..."
        /usr/sbin/dseditgroup -o edit -a $3 -t user admin
        if [[ "$?" == 0 ]]; then
            echo "$3" > /private/var/ADlocalAdminSet
            exit 0
        else
            echo "Operation not successful"
            exit 1
        fi
    else
        echo "$3 is already an admin. Exiting..."
        exit 0
    fi
else
    echo "$3 is not an Active Directory account. Exiting..."
    exit 0
fi