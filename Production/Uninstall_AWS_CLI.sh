#!/bin/bash 

###############################################################################
#
# Name: Uninstall_AWS_CLI.sh
# Version: 1.0
# Create Date:  11 February 2017
# Last Modified:
#
# Author:  Adam Shuttleworth
# Purpose: This script uninstalls AWS CLI
#
###############################################################################
# Check if AWS CLI is installed. If not, exit script.
AWS=$( aws --version )

if [[ ! -z $AWS ]];then 
	echo "AWS CLI is not installed."
	exit 0
fi

# Check if AWS was installed via bundled installer and uninstall
if [[ ! -f /usr/local/aws ]] && [[ -f /usr/local/bin/aws ]]; then
	rm -rf /usr/local/aws
	rm /usr/local/bin/aws
else
	# Check if PIP is installed 
	PIP=$( pip3 --version )
	if [[ -z $PIP ]]; then
		pip3 uninstall awscli
	fi
fi

# Check if AWS CLI installed successfully
AWS=`aws --version`

if [[ ! -z AWS ]]; then 
	echo "AWS CLI uninstalled successfully."
	exit 0
else
	echo "AWS CLI not uninstalled properly."
	exit 1
fi



