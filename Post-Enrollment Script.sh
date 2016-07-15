#!/bin/bash
# Author: Adam Shuttleworth
# Created: 2016-06-22
# Modified: 2016-06-22
# Name: Post-Enrollment Script

################################################################################

## Post-Enrollment Actions

# Copy Local Admin Script and Launch Agent to Computer
	jamf policy -trigger localAdmin

# Install Office 2016 and Lync 2011
	jamf policy -trigger office2016
	jamf policy -trigger lync2011
	
# Set EFI PW
	jamf policy -trigger setEFIPW

# Run Baseline Configuration
	jamf policy -trigger baseConfig

################################################################################
