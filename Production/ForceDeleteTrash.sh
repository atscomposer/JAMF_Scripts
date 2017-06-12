#!/bin/bash

###############################################################################
#
# Name: ForceDeleteTrash.sh
# Version: 1.0
# Create Date:  02 February 2017
# Last Modified:
#
# Author:  Adam Shuttleworth
# Purpose: Script to force delete trash of logged in user.
#
###############################################################################

## Get logged in user's username
currentUser=`stat -f%Su /dev/console`

## Foce delete logged in user's Trash
su "$currentUser" -c "rm -rf ~/.Trash/* && killall Dock"
