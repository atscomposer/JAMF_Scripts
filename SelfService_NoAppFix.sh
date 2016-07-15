#!/bin/bash

/usr/libexec/PlistBuddy -c "add LSHandlers:0 dict" /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist

/usr/libexec/PlistBuddy -c "add LSHandlers:0:LSHandlerPreferredVersions dict" /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist

/usr/libexec/PlistBuddy -c "add LSHandlers:0:LSHandlerPreferredVersions:LSHandlerRoleAll string -" /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist

/usr/libexec/PlistBuddy -c "add LSHandlers:0:LSHandlerRoleAll string com.jamfsoftware.selfservice" /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist

/usr/libexec/PlistBuddy -c "add LSHandlers:0:LSHandlerURLScheme string selfservice" /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist