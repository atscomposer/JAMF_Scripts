#!/bin/sh

###############################################################################
#
# Name: EnableOneDriveExtension.sh
# Version: 1.0
# Create Date:  28 September 2016
# Last Modified:
#
# Author:  Adam Shuttleworth
# Purpose:  Script to enable OneDrive Extension in System Preferences-->Extensions
#
###############################################################################

###################### Get current user ########################

CurrentUser=`ls -l /dev/console | cut -d " " -f4`

############# Run the Command as the currently logged in user ################

su -l "${CurrentUser}" -c '/usr/bin/pluginkit -e use -i com.microsoft.OneDrive-mac.FinderSync'

exit 0
