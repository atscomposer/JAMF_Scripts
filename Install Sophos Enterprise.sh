#!/bin/sh
####################################################################################################
#
# Created By: Adam Shuttleworth
# Date Created: 5/23/2016
# Description: Script to remove System Center Endpoint Protection and install Sophos Enterprise
#
#
####################################################################################################

#!/bin/sh
#Script for uninstalling the Microsoft System Center Endpoint Protection client for Mac

#Attempt to kill FW processes
/usr/bin/killall scep_gui

#Remove the varios FW installed bits and pieces
/bin/rm -rf /Applications/System\ Center\ 2012\ Endpoint\ Protection.app
/bin/rm -rf /Applications/System\ Center\ Endpoint\ Protection.app

#Tell the system to forget that FW was ever installed
/usr/sbin/pkgutil --forget com.microsoft.systemCenter2012EndpointProtection.com.microsoft.scep_daemon.pkg
/usr/sbin/pkgutil --forget com.microsoft.systemCenter2012EndpointProtection.GUI_startup.pkg
/usr/sbin/pkgutil --forget com.microsoft.systemCenter2012EndpointProtection.pkgid.pkg
/usr/sbin/pkgutil --forget com.microsoft.systemCenter2012EndpointProtection.scep_kac_64_106.pkg
/usr/sbin/pkgutil --forget com.microsoft.systemCenter2012EndpointProtection.scepbkp.pkg
/usr/sbin/pkgutil --forget com.microsoft.systemCenter2012EndpointProtection.SystemCenter2012EndpointProtection.pkg
/usr/sbin/pkgutil --forget com.microsoft.systemCenterEndpointProtection.com.microsoft.scep_daemon.pkg
/usr/sbin/pkgutil --forget com.microsoft.systemCenterEndpointProtection.GUI_startup.pkg
/usr/sbin/pkgutil --forget com.microsoft.systemCenterEndpointProtection.pkgid.pkg
/usr/sbin/pkgutil --forget com.microsoft.systemCenterEndpointProtection.scep_kac_64_106.pkg
/usr/sbin/pkgutil --forget com.microsoft.systemCenterEndpointProtection.scepbkp.pkg
/usr/sbin/pkgutil --forget com.microsoft.systemCenterEndpointProtection.SystemCenterEndpointProtection.pkg

#Install Sophos Enterprise (Latest Version)---Pulls Installer from the Sophos Cloud
cd /Users/Shared/
rm -R Sophos*
curl -O https://dzr-api-amzn-us-west-2-fa88.api-upe.p.hmr.sophos.com/api/download/97d6feb0fe59632b5451a05fbba19ba8/SophosInstall.zip
unzip SophosInstall.zip &> /dev/null
chmod -R +x /Users/Shared/Sophos\ Installer.app/
/Users/Shared/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer --install
rm -R Sophos*
exit
