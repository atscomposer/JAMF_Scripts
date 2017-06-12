#!/bin/bash

###############################################################################
#
# Name: Install_AWS_CLI.sh
# Version: 1.0
# Create Date:  10 February 2017
# Last Modified: 11 February 2017
#
# Author:  Adam Shuttleworth
# Purpose: This script installs AWS CLI
#
################################################################################
PWD=`pwd`
rm -rf ${PWD}/awscli-bundle.zip
rm -rf ${PWD}/awscli-bundle

# Check Python version
PYTHON=`python --version`

if [[ ! -z "$PYTHON" ]]; then
	echo "Python is not installed."
	exit 1
else
	echo "Python is installed."
fi

# Download AWS CLI Bundled Installer
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"

# Unzip Package
unzip awscli-bundle.zip

# Run Executable
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# Update PIP
pip3 install --upgrade pip

# Check if AWS CLI installed successfully
AWS=`aws --version`

if [[ ! -z AWS ]]; then 
	echo "AWS CLI installed successfully."
	PWD=`pwd`
	rm -rf ${PWD}/awscli-bundle.zip
	rm -rf ${PWD}/awscli-bundle
	exit 0
else
	echo "AWS CLI not installed properly."
	exit 1
fi


