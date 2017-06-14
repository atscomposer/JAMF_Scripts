#!/bin/bash

###############################################################################
#
# Name: macOSVersionCheck.sh
# Version: 1.0
# Create Date:  20 January 2017
# Last Modified: 14 June 2017
#
# Author:  Adam Shuttleworth
# Purpose:  This script checks the running macOS version
#
###############################################################################

# Get the current OS version to serve as an example
THIS_OS=$(sw_vers -productVersion)

# Determine if the OS version starts with "10."
echo "${THIS_OS}" | grep -q -e '^10.'

case $? in
    # If the OS version matches the initial basic criteria,
    # then determine if it is greater than a specific OS X version
    # by string comparison against lower major version numbers.
    0)
        # Eliminate each major OS X version, one by one, with string matching.
        # Stop with the version before the one of interest.
        echo "${THIS_OS}" | \
            grep -v -q \
                -e '^10.8.' \
                -e '^10.9.' \
                -e '^10.10.' && \
                echo "OS running is greater than 10.11 (${THIS_OS})."
        ;;
    *)
        echo "OS X version number not found."
        ;;
esac