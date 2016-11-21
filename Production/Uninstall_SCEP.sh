#!/bin/sh
#Script for uninstalling the Microsoft System Center Endpoint Protection client for Mac

#Attempt to kill FW processes
/usr/bin/killall scep_gui

#Remove the varios FW installed bits and pieces
/bin/rm -rf /Applications/System\ Center\ 2012\ Endpoint\ Protection.app

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