#!/bin/sh

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
