#!/bin/bash

###############################################################################
#
# Name: ResetPrintSystem.sh
# Version: 1.0
# Create Date:  01 February 2017
# Last Modified:
#
# Author:  bpavlov (JAMFNATION: https://www.jamf.com/jamf-nation/discussions/8695/programmatically-reset-printing-system-via-command-line)
# Adapted By: Adam Shuttleworth
# Purpose: This script will reset printing system  
#
###############################################################################

#Stop CUPS
launchctl stop org.cups.cupsd

#Backup Installed Printers Property List
if [ -e "/Library/Printers/InstalledPrinters.plist" ]
    then
    mv /Library/Printers/InstalledPrinters.plist /Library/Printers/InstalledPrinters.plist.bak
fi

#Backup the CUPS config file
if [ -e "/etc/cups/cupsd.conf" ]
    then
    mv /etc/cups/cupsd.conf /etc/cups/cupsd.conf.bak
fi

#Restore the default config by copying it
if [ ! -e "/etc/cups/cupsd.conf" ]
    then
    cp /etc/cups/cupsd.conf.default /etc/cups/cupsd.conf
fi

#Backup the printers config file
if [ -e "/etc/cups/printers.conf" ]
    then
    mv /etc/cups/printers.conf /etc/cups/printers.conf.bak
fi

#Start CUPS
launchctl start org.cups.cupsd

#Remove all printers
lpstat -p | cut -d' ' -f2 | xargs -I{} lpadmin -x {}

#Run Recon after Reset
jamf recon

exit 0