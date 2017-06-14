#!/bin/sh -x

###############################################################################
#
# Name: Uninstall_All_Managed_Printers.sh
# Version: 1.0
# Create Date:  20 January 2017
# Last Modified: 14 June 2017
#
# Author:  Adam Shuttleworth
# Purpose:  Script uninstalls all managed printers from print server(s)
# 
#
###############################################################################

# Hardcoded Variables
printservers=(
"GZ_PRINT_01"
"HQ_PRINTSRV"
"JP_PRINT_01"
"HK_PRINT_01"
"PAS_PRINT_01"
)

for print in "${printservers[@]}"; do
# Find all installed printer from specified  
lpstat -p | cut -d' ' -f2 | grep "$print" | xargs -I{} lpadmin -x {}
done

# Run JAMF Pro Recon to ensure computer is proper Smart Computer Group
jamf recon
