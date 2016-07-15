#!/bin/sh
jamf recon -endUsername "a" -realname "a" -email "a" -position "a" -building " " -department " " -phone "1"
lastUser=`defaults read /Library/Preferences/com.apple.loginwindow lastUserName`
jamf recon -endUsername $lastUser
