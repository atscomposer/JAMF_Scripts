#!/bin/sh

###############################################################################
#
# Name: Office_Templates_Update.sh
# Version: 1.0
# Create Date:  7 October 2016
# Last Modified: 12 June 2017
#
# Author:  Adam Shuttleworth
# Purpose:  Script to copy the iRobot PowerPoint and Word Doc templates from
# /path/to/templatesPath to all users' O365 templates directory.
#
# Required: iRobot PowerPoint and Word Templates to be distributed to client machines to same path as templatesPath variable.
#
# JAMF Pro Setup:
# 	1. Create Package with Word and PPT templates at same path as templatesPath variable in DMG through JAMF Composer
# 	2. Create JAMF Policy
# 		- Frequency: Once per computer
#		- Package: Templates DMG created in step 1
#		- Script: This script with the following Parameters:
#			Parm 4: Deployment Date (i.e. 20170612)
#			Parm 5: Template Path (i.e. - /Library/SharedFolder)
#			Parm 6: Default O365 templates directory (i.e. - Library/Group Containers/UBF8T346G9.Office/User Content.localized/Templates.localized)
#			Parm 7: Word Template Name (i.e. - CompanyName.dotm)
#			Parm 8: PPT Template Name (i.e. - CompanyName.potx)
#		- Scope: All Computers
#
#	To Update templates a second time:
#		1. Create new Package with new Word and PPT templates
#		2. Change Deployment Date Variable of the script in the JAMF policy
# 	
###############################################################################

# Modify this variable to the current date
timestamp="20161014"

## Hardcoded values for testing
templatesPath="/path/to/templatesfolder/"
officeTemplatesLoc="Library/Group Containers/UBF8T346G9.Office/User Content.localized/Templates.localized"
wordTempName="{filename}.dotm"
pptTempName="{filename}.pptm"

## Variable values from JAMF
if [[ "$timestamp" == "" ]] && [[ "$4" != "" ]]; then
    timestamp="$4"
elif [[ "$timestamp" == "" ]] && [[ "$4" == "" ]]; then
    echo "Current Date was not specified in parameter 4. Script cannot execute. Exiting..."
    exit 1
fi
if [[ "$templatePath" == "" ]] && [[ "$5" != "" ]]; then
    templatePath="$5"
elif [[ "$templatePath" == "" ]] && [[ "$5" == "" ]]; then
    echo "Template path was not specified in parameter 5. Script cannot execute. Exiting..."
    exit 1
fi
if [[ "$officeTemplatesLoc" == "" ]] && [[ "$6" != "" ]]; then
    officeTemplatesLoc="$6"
elif [[ "$officeTemplatesLoc" == "" ]] && [[ "$6" == "" ]]; then
    echo "Office Templates Path Location was not specified in parameter 6. Script cannot execute. Exiting..."
    exit 1
fi
if [[ "$wordTempName" == "" ]] && [[ "$7" != "" ]]; then
    wordTempName="$7"
elif [[ "$wordTempName" == "" ]] && [[ "$7" == "" ]]; then
    echo "Word Template Name was not specified in parameter 7. Script cannot execute. Exiting..."
    exit 1
fi
if [[ "$pptTempName" == "" ]] && [[ "$8" != "" ]]; then
    pptTempName="$8"
elif [[ "$pptTempName" == "" ]] && [[ "$8" == "" ]]; then
    echo "PPT Template Name was not specified in parameter 8. Script cannot execute. Exiting..."
    exit 1
fi

# Cycle through all users, except those defined, and check if Word and PPT templates exist and are up-to-date 
cd /Users
for AUSER in *
do
if [ "$AUSER" != *\(Deleted\) -a "$AUSER" != "Shared" -a "$AUSER" != "Guest" -a "$AUSER" != "irbt" -a "$AUSER" != "svc_forescout" ]; then
	# Check if Word Template already exists in proper location.  If not, copy it there. If so, check if it is the ost up-to-date version
	if [ ! -f "/Users/$AUSER/${officeTemplatesLoc}/${wordTempName}" ]; then
		cp "${templatesPath}/${wordTempName}" "/Users/$AUSER/${officeTemplatesLoc}/"
		chown "$AUSER" "/Users/$AUSER/${officeTemplatesLoc}/${wordTempName}"
	else
		wordtimestamp=$(stat -f "%Sm" -t "%Y%m%d" "/Users/$AUSER/${officeTemplatesLoc}/${wordTempName}")
		if [[ "$wordtimestamp" != "" ]] && [[ ! "$timestamp" == "$wordtimestamp" ]]; then
			cp "${templatesPath}/${wordTempName}" "/Users/$AUSER/${officeTemplatesLoc}/"
			chown "$AUSER" "/Users/$AUSER/${officeTemplatesLoc}/${wordTempName}"
		fi
	fi
	# Check if PPT Template already exists in proper location.  If not, copy it there. If so, check if it is the ost up-to-date version
	if [ ! -f "/Users/$AUSER/${officeTemplatesLoc}/${pptTempName}" ]; then
		cp "${templatesPath}/${pptTempName}" "/Users/$AUSER/${officeTemplatesLoc}/"
		chown "$AUSER" "/Users/$AUSER/${officeTemplatesLoc}/${pptTempName}"
	else
		PPTtimestamp=$(stat -f "%Sm" -t "%Y%m%d" "/Users/$AUSER/${officeTemplatesLoc}/${pptTempName}")
		if [[ "$PPTtimestamp" != "" ]] && [[ ! "$timestamp" == "$PPTtimestamp" ]]; then
			cp "${templatesPath}/${pptTempName}" "/Users/$AUSER/${officeTemplatesLoc}/"
			chown "$AUSER" "/Users/$AUSER/${officeTemplatesLoc}/${pptTempName}"
		fi
	fi
fi
done
exit $@

exit 0		## Success
exit 1		## Failure
